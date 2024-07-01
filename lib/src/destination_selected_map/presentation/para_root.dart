import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/constants/graphQL/graphql_base_queries.dart';
import 'package:para_client/core/constants/graphQL/graphql_config.dart';
import 'package:para_client/core/services/convert_to_dms.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/core/services/seconds_to_readable.dart';
import 'package:para_client/core/services/unpack_polyline.dart';
import 'package:para_client/src/alerts_module/domain/alert_model.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_bloc.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_event.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_state.dart';
import 'package:para_client/src/destination_selected_map/domain/graphql/itinerary_model.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';
import 'package:para_client/src/destination_selected_map/presentation/widgets/leaflet_map.dart';
import 'package:para_client/widgets/shim.dart';

// ignore: must_be_immutable
class ParaRoot extends StatefulWidget {
  ParaRoot(
      {super.key,
      this.origin,
      this.destination,
      this.feature,
      this.fareClass,
      this.time});

  LatLng? origin;
  LatLng? destination;
  final Feature? feature;
  FareClasses? fareClass;
  TimeOfDay? time;

  @override
  State<ParaRoot> createState() => _ParaRootState();
}

class _ParaRootState extends State<ParaRoot> {
  final controller = TextEditingController();
  final controllerOrigin = TextEditingController();
  final controllerDestination = TextEditingController();
  final pageContoller = PageController();
  final draggableScrollSheetController = DraggableScrollableController();

  // ignore: unused_field

  LatLng? origin;
  LatLng? destination;
  LatLng? _center;
  LatLngBounds? _bounds;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isSwap = false;
  bool isWaiting = false;

  String bottomDestText = '';
  bool isPressed = false;
  bool itinerariesReady = false;
  bool markersReady = false;
  String reverseMode = 'destination';
  bool _refetchRequested = false;
  bool _itineraryChosen = false;
  bool _rebuildMarkers = false;
  bool _recenter = false;
  bool _rebuildToChosen = false;
  bool _rebuildToItineraries = false;

  int _bottomSheetIndex = 0;

  // final GlobalKey<Query> _queryKey = GlobalKey<QueryState>();
  List<ItineraryModel>? _itineraries;
  Map<int, List<double>>? _itineraryFares;
  Map<int, Color>? _itineraryColors;
  Map<int, List<String>>? _itineraryLegRouteTypes;

  List<ItineraryModel>? _chosenItineraries;
  Map<int, List<double>>? _chosenItineraryFares;
  Map<int, Color>? _chosenItineraryColors;
  Map<int, List<String>>? _chosenItineraryLegRouteTypes;

  final db = fs.FirebaseFirestore.instance;
  late fs.CollectionReference faresColRef;
  late fs.CollectionReference routesColRef;
  late fs.CollectionReference frequenciesColRef;

  late fs.CollectionReference alertsColRef;

  List<Map<String, dynamic>> fares = [];
  List<Map<String, dynamic>> routeTypes = [];
  List<TimeOfDay> serviceWindow = [];

  List<Alert> alerts = [];
  bool _showAlerts = true;

  FareClasses? fareClass;

  @override
  void initState() {
    super.initState();

    if (widget.origin != null) {
      String lat = convertLatLng(widget.origin!.latitude, true);
      String lon = convertLatLng(widget.origin!.longitude, false);
      controllerOrigin.text = '$lat, $lon';

      setState(() {
        reverseMode = 'origin';
      });

      context.read<RemoteReverseBloc>().add(GetReverseFeatures(
            lat: widget.origin!.latitude,
            lon: widget.origin!.longitude,
          ));

      setState(() {
        origin = widget.origin;
      });
    } else {
      getLastKnownLocation().then(
        (value) {
          if (value != null) {
            setState(() {
              origin = LatLng(value.latitude, value.longitude);
            });
          } else {
            getCurrentLocation().then(
              (value) {
                setState(() {
                  origin = LatLng(value.latitude, value.longitude);
                });
              },
            );
          }

          controllerOrigin.text = 'Your location';
          return value;
        },
      );
    }

    if (widget.destination != null) {
      String lat = convertLatLng(widget.destination!.latitude, true);
      String lon = convertLatLng(widget.destination!.longitude, false);
      controller.text = '$lat, $lon';
      controllerDestination.text = '$lat, $lon';

      setState(() {
        reverseMode = 'destination';
      });

      context.read<RemoteReverseBloc>().add(GetReverseFeatures(
            lat: widget.destination!.latitude,
            lon: widget.destination!.longitude,
          ));

      setState(() {
        bottomDestText = controller.text;
      });

      // setState(() {
      //   _bottomNavChild = BottomNavWidget(
      //     bottomDestText: bottomDestText,
      //     handleInkWellTap: handleInkWellTap,
      //   );
      // });
    }

    if (widget.feature != null) {
      String lat =
          convertLatLng(widget.feature!.geometry!.coordinates![1], true);
      String lon =
          convertLatLng(widget.feature!.geometry!.coordinates![0], false);

      if (widget.feature!.properties!.name != null) {
        controller.text = '${widget.feature!.properties!.name}';
        controllerDestination.text = '${widget.feature!.properties!.name}';
      } else {
        controller.text = '$lat, $lon';
        controllerDestination.text = '$lat, $lon';
      }

      setState(() {
        widget.destination = LatLng(
          widget.feature!.geometry!.coordinates![1],
          widget.feature!.geometry!.coordinates![0],
        );
      });
    }

    setState(() {
      fareClass = widget.fareClass ?? FareClasses.regular;
    });

    faresColRef = db.collection('_meta-fares-per-type-and-class');
    routesColRef = db.collection('_meta-route-types');
    frequenciesColRef = db.collection('frequencies');
    alertsColRef = db.collection('_meta-community-alerts');

    fetchFares();
    fetchFrequencies();

    fetchCommunityAlerts();

    selectedDate = DateTime.now();
    selectedTime = widget.time ?? TimeOfDay.now();

    // fetchRoutes();

    // faresColRef.get().then();
    // });

    // graphqlClient = context.read<GraphqlConfig>().clientToQuery();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchFares() async {
    fs.QuerySnapshot querySnapshot = await faresColRef.get();
    setState(() {
      fares = querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      // print(fares);
    });
  }

  Future<void> fetchFrequencies() async {
    List<Map<String, dynamic>> frequencies = [];
    fs.QuerySnapshot querySnapshot = await frequenciesColRef.get();
    frequencies = querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();

    String earliestStartTime = frequencies
        .map((e) => e['start_time'] as String)
        .reduce((value, element) {
      if (value.compareTo(element) < 0) {
        return value;
      } else {
        return element;
      }
    });

    String latestEndTime = frequencies
        .map((e) => e['end_time'] as String)
        .reduce((value, element) {
      if (value.compareTo(element) > 0) {
        return value;
      } else {
        return element;
      }
    });
    // Get earliest start time and latest end time

    setState(() {
      serviceWindow = [
        TimeOfDay(
          hour: int.parse(earliestStartTime.split(":")[0]),
          minute: int.parse(earliestStartTime.split(":")[1]),
        ),
        TimeOfDay(
          hour: int.parse(latestEndTime.split(":")[0]),
          minute: int.parse(latestEndTime.split(":")[1]),
        ),
      ];
    });
    // print(fares);
  }

  Future<void> fetchRoutes() async {
    fs.QuerySnapshot querySnapshot = await routesColRef.get();
    setState(() {
      routeTypes = querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  Future<void> fetchCommunityAlerts() async {
    // List<Alert> alerts = [];
    fs.QuerySnapshot querySnapshot = await alertsColRef.get();

    // alerts = querySnapshot.docs.map((doc) => Alert.fromSnapshot(doc)).toList();
    setState(() {
      alerts =
          querySnapshot.docs.map((doc) => Alert.fromSnapshot(doc)).toList();
    });

    // print(alerts);
  }

  // Future<List<Alert>> fetchAlerts() async {
  //   fs.QuerySnapshot querySnapshot = await alertsColRef
  //       .get();

  //   return querySnapshot.docs.map((doc) => Alert.fromSnapshot(doc)).toList();
  // }

  void handleInkWellTap() async {
    if (isWaiting || destination == null || origin == null) {
      _showSnackbar();
      return;
    }

    setState(() {
      isPressed = !isPressed;

      // print("check");
      // print(isPressed);
      // print(itinerariesReady);
    });

    if (!isPressed) {
      setState(() {
        itinerariesReady = false;
      });
    }
  }

  void _showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // width: MediaQuery.of(context).size.width * 0.8,
        // padding: EdgeInsets.symmetric(horizontal: 64.0),
        width: MediaQuery.of(context).size.width * 0.75,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        )),
        content: const Center(child: Text('Resources still loading')),
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.down,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = isPressed
        ? (_itineraryChosen ? screenHeight * 0.1 : screenHeight * 0.2)
        : screenHeight * 0.08;

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: isPressed
                ? (_itineraryChosen
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 48, 8, 0),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: IconButton(
                                  onPressed: () => {Navigator.pop(context)},
                                  icon: const Icon(CupertinoIcons.xmark),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Trip started',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                  )),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 48, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 80),
                              child: IconButton(
                                onPressed: () => {Navigator.pop(context)},
                                icon: const Icon(CupertinoIcons.back),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.radio_button_checked,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    Icons.more_vert,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    Icons.room_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 4),
                                      height: 58,
                                      child: TextField(
                                        controller: controllerOrigin,
                                        style: textTheme.displaySmall?.copyWith(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 16),
                                        ),
                                        readOnly: true,
                                        onTap: () => {
                                          Navigator.pushNamed(
                                              context, '/search',
                                              arguments: {
                                                'mode': 'loc-picker',
                                                'initialCenter': origin,
                                              }).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                if (value.runtimeType ==
                                                    LatLng) {
                                                  LatLng temp = value as LatLng;
                                                  reverseMode = 'origin';
                                                  context
                                                      .read<RemoteReverseBloc>()
                                                      .add(GetReverseFeatures(
                                                          lat: temp.latitude,
                                                          lon: temp.longitude));
                                                } else {
                                                  origin = LatLng(
                                                      (value as Feature)
                                                          .geometry!
                                                          .coordinates![1],
                                                      value.geometry!
                                                          .coordinates![0]);
                                                  controllerOrigin.text =
                                                      value.properties!.name!;
                                                }

                                                // print('Origin: $origin');
                                                _refetchRequested = true;
                                                isPressed = true;
                                                _bottomSheetIndex = 0;
                                              });
                                            }
                                          })
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 4, 0, 8),
                                      height: 58,
                                      child: TextField(
                                        controller: controllerDestination,
                                        style: textTheme.displaySmall?.copyWith(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 16),
                                        ),
                                        readOnly: true,
                                        onTap: () => {
                                          Navigator.pushNamed(
                                              context, '/search',
                                              arguments: {
                                                'mode': 'loc-picker',
                                                'initialCenter': origin,
                                                'initialQuery':
                                                    controllerDestination.text
                                              }).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                if (value.runtimeType ==
                                                    LatLng) {
                                                  LatLng temp = value as LatLng;
                                                  reverseMode = 'destination';
                                                  context
                                                      .read<RemoteReverseBloc>()
                                                      .add(GetReverseFeatures(
                                                          lat: temp.latitude,
                                                          lon: temp.longitude));
                                                } else {
                                                  destination = LatLng(
                                                      (value as Feature)
                                                          .geometry!
                                                          .coordinates![1],
                                                      value.geometry!
                                                          .coordinates![0]);
                                                  controllerDestination.text =
                                                      value.properties!.name!;
                                                }
                                                _refetchRequested = true;
                                                isPressed = true;
                                                _bottomSheetIndex = 0;
                                              });
                                            }
                                          })
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () => {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return _buildOptionsDialogWidget();
                                        },
                                      ).then((value) {
                                        setState(() {});
                                      })
                                    },
                                    icon: const Icon(Icons.more_horiz),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                : AppBar(
                    backgroundColor: isPressed
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                    elevation: !isPressed ? 0 : 4,
                    shape: !isPressed
                        ? const Border()
                        : const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                    leading: !isPressed
                        ? null
                        : IconButton(
                            onPressed: () => {
                              handleInkWellTap(),
                            },
                            icon: const Icon(CupertinoIcons.back),
                          ),
                    title: Container(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 3,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller,
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
                          readOnly: true,
                          onTap: () => {
                            Navigator.pushNamed(context, '/search', arguments: {
                              'mode': 'para_root',
                              'initialQuery': controller.text
                            })
                          },
                        ),
                      ),
                    ),
                    automaticallyImplyLeading: false,
                  )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocListener<RemoteReverseBloc, RemoteReverseState>(
          listener: (context, state) {
            // print(state);
            // if (state is RemoteReverseSuccess) {
            //   print(state.features.isNotEmpty);
            // }
            if (state is RemoteReverseSuccess && state.features.isNotEmpty) {
              if (state.features[0].properties!.name != null) {
                controller.text = state.features[0].properties!.name!;
                if (reverseMode == 'destination') {
                  setState(() {
                    controllerDestination.text =
                        state.features[0].properties!.name!;
                    bottomDestText = controller.text;
                    destination = LatLng(
                      state.features[0].geometry!.coordinates![1],
                      state.features[0].geometry!.coordinates![0],
                    );
                  });
                } else {
                  setState(() {
                    controllerOrigin.text = state.features[0].properties!.name!;
                    origin = LatLng(
                      state.features[0].geometry!.coordinates![1],
                      state.features[0].geometry!.coordinates![0],
                    );
                    // _refetchRequested = true;
                  });
                }
              }
            }
          },
          child: BlocBuilder<RemoteReverseBloc, RemoteReverseState>(
            builder: (context, state) {
              if (state is RemoteReverseLoading) {
                isWaiting = true;
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (state is RemoteReverseError) {
                isWaiting = false;
                return const Center(
                  child: Icon(CupertinoIcons.refresh),
                );
              } else if (state is RemoteReverseSuccess) {
                if (_rebuildToChosen) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      _bottomSheetIndex = 0;
                      pageContoller.jumpToPage(0);
                      _rebuildToChosen = false;
                      _itineraryChosen = true;
                    });
                  });

                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                if (_rebuildToItineraries) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      _bottomSheetIndex = 0;
                      pageContoller.jumpToPage(0);

                      _rebuildToItineraries = false;
                      itinerariesReady = true;
                      // _refetch();
                    });
                  });

                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                if (_recenter) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      // _center =
                      _recenter = false;
                    });
                  });

                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                if (_itineraryChosen) {
                  if (_center != null) {
                    return LeafletMap(
                      initCenter: _center,
                      initZoom: 17,
                      // bounds: _bounds,
                      destination: destination,
                      origin: origin,
                      itineraries: _chosenItineraries,
                      itineraryColors: _chosenItineraryColors,
                      itineraryLegRouteTypes: _chosenItineraryLegRouteTypes,
                      alerts: _showAlerts == true ? alerts : null,
                    );
                  }
                  return LeafletMap(
                    destination: destination,
                    origin: origin,
                    itineraries: _chosenItineraries,
                    itineraryColors: _chosenItineraryColors,
                    itineraryLegRouteTypes: _chosenItineraryLegRouteTypes,
                    alerts: _showAlerts == true ? alerts : null,
                  );
                }
                if (!isPressed) {
                  isWaiting = false;
                  return LeafletMap(
                    destination: destination,
                    origin: origin,
                  );
                } else if (!itinerariesReady) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                } else if (itinerariesReady) {
                  // itinerariesReady = false; // Uncomment if needed
                  isWaiting = false;
                  return LeafletMap(
                    destination: destination,
                    origin: origin,
                    itineraries: _itineraries,
                    itineraryColors: _itineraryColors,
                    itineraryLegRouteTypes: _itineraryLegRouteTypes,
                    alerts: _showAlerts == true ? alerts : null,
                  );
                }
              }

              return LeafletMap(
                destination: destination,
                origin: origin,
              );
            },
          ),
        ),
        bottomNavigationBar: isPressed
            ? (_refetchRequested
                ? _refetch()
                : _buildDraggableScrollSheetWidget())
            : _buildBottomNavWidget(),
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _refetch() {
    setState(() {
      _itineraries = null;
      _itineraryFares = null;
      _itineraryColors = null;
      _itineraryLegRouteTypes = null;
      _bottomSheetIndex = 0;
      itinerariesReady = false;
      _refetchRequested = false;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildBottomNavWidget() {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                bottomDestText,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: handleInkWellTap,
                child: Ink(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Select Destination',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child:
                                Icon(Icons.directions_car, color: Colors.white),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatefulWidget _buildOptionsDialogWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Trip Options',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select fare class",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ListTile(
                title: const Text('Regular Fare'),
                leading: Radio<FareClasses>(
                  value: FareClasses.regular,
                  groupValue: fareClass,
                  onChanged: (FareClasses? value) {
                    setState(() {
                      fareClass = value;
                      _itineraryFares =
                          computeFares(_itineraries!, fares, fareClass!);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Discounted Fare'),
                leading: Radio<FareClasses>(
                  value: FareClasses.discounted,
                  groupValue: fareClass,
                  onChanged: (FareClasses? value) {
                    setState(() {
                      fareClass = value;
                      _itineraryFares =
                          computeFares(_itineraries!, fares, fareClass!);
                    });
                  },
                ),
              ),
              const Shim(height: 16),
              // Checkbox list tile for alerts
              ListTile(
                title: const Text('Show Community Alerts'),
                leading: Checkbox(
                  value: _showAlerts,
                  onChanged: (bool? value) {
                    setState(() {
                      _showAlerts = value!;
                      _refetchRequested = true;
                    });
                  },
                ),
              ),

              // ListTile(
              //   title: const Text('Select Date'),
              //   subtitle: Text(selectedDate.toString().split(" ")[0]),
              //   onTap: () async {
              //     DateTime? date = await showDatePicker(
              //       context: context,
              //       initialDate: selectedDate!,
              //       firstDate: DateTime.now(),
              //       lastDate: DateTime.now().add(const Duration(days: 30)),
              //     );

              //     if (date != null) {
              //       setState(() {
              //         selectedDate = date;
              //       });
              //     }
              //   },
              // ),
              ListTile(
                title: const Text('Departure time'),
                subtitle: Text(selectedTime!.format(context)),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime!,
                  );

                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                      _refetchRequested = true;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                fetchFares();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableScrollSheetWidget() {
    // Determine screen height
    final screenHeight = MediaQuery.of(context).size.height;

    // Define child size variables
    double initialChildSize = 0.3;
    double minChildSize = 0.3;
    double maxChildSize = 0.6;

    List<double> snapSizes = _itineraryChosen
        ? const [
            0.3,
          ]
        : const [
            0.3,
            0.4,
            0.6,
          ];

    // Adjust sizes for smaller screens
    if (screenHeight < 800) {
      initialChildSize = 0.4;
      minChildSize = 0.4;
      maxChildSize = 0.6;

      snapSizes = _itineraryChosen
          ? const [
              0.4,
            ]
          : const [
              0.4,
              0.6,
            ];
    }

    return Animate(
      effects: const [
        SlideEffect(
          begin: Offset(0, 1),
          end: Offset(0, 0),
          duration: Duration(milliseconds: 200),
        ),
      ],
      child: Query(
        options: QueryOptions(
            document: gql(getItinerariesQuery),
            variables: {
              'fromLat': origin!.latitude,
              'fromLon': origin!.longitude,
              'toLat': destination!.latitude,
              'toLon': destination!.longitude,
              'date': selectedDate.toString().split(" ")[0],
              'time': twelveToTwentyFourHour(selectedTime!),
              'transportModes': const [
                {'mode': 'TRANSIT'},
              ],
            },
            onComplete: (result) {
              List? res = result?['plan']['itineraries'];

              if (res != null) {
                _itineraries =
                    List.of(res.map((e) => ItineraryModel.fromMap(e)));

                if (_itineraries!.isNotEmpty) {
                  // TODO : Remove if router is optimized
                  // _itineraries = cleanItineraries(_itineraries!);

                  // Compute fares
                  _itineraryFares =
                      computeFares(_itineraries!, fares, fareClass!);

                  _itineraryColors =
                      generateItineraryColors(_itineraries!.length);

                  _itineraryLegRouteTypes =
                      generateLegRouteTypes(_itineraries!);

                  if (_itineraries!.length > 1) {
                    // Sort based on duration
                    _itineraries = sortByDuration(_itineraries!);
                    _itineraryFares =
                        computeFares(_itineraries!, fares, fareClass!);
                    _itineraryColors =
                        generateItineraryColors(_itineraries!.length);
                    _itineraryLegRouteTypes =
                        generateLegRouteTypes(_itineraries!);

                    // Add sort by fare later
                  }

                  setState(() {
                    itinerariesReady = true;
                  });

                  if (serviceWindow[0].hour > selectedTime!.hour ||
                      serviceWindow[1].hour < selectedTime!.hour) {
                    String meridian = selectedTime!.hour > 12 ? "PM" : "AM";
                    String startMeridian =
                        serviceWindow[0].hour > 12 ? "PM" : "AM";
                    String endMeridian =
                        serviceWindow[1].hour > 12 ? "PM" : "AM";

                    String selected = selectedTime!.hour > 12
                        ? "${selectedTime!.hour - 12}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                        : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                    String start = serviceWindow[0].hour > 12
                        ? "${serviceWindow[0].hour - 12}:${serviceWindow[0].minute.toString().padLeft(2, '0')}"
                        : "${serviceWindow[0].hour}:${serviceWindow[0].minute.toString().padLeft(2, '0')}";

                    String end = serviceWindow[1].hour > 12
                        ? "${serviceWindow[1].hour - 12}:${serviceWindow[1].minute.toString().padLeft(2, '0')}"
                        : "${serviceWindow[1].hour}:${serviceWindow[1].minute.toString().padLeft(2, '0')}";

                    // Show dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Icon(CupertinoIcons.clock,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              const Text('Warning'),
                            ],
                          ),
                          content: SizedBox(
                            height: 96,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "It's $selected $meridian: some trips unavailable",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Shim(height: 8),
                                Text(
                                  "Currently, the service window for all trips is from $start $startMeridian to $end $endMeridian. Consider adjusting the departure time to see more options.",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // show dialog
                  setState(() {
                    itinerariesReady = true;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(
                                  CupertinoIcons.exclamationmark_triangle,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const Text('No itineraries found'),
                          ],
                        ),
                        content: SizedBox(
                          height: 96,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "No itineraries found",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Shim(height: 8),
                              Text(
                                "Please adjust your search parameters and try again.",
                                style: Theme.of(context).textTheme.bodySmall!,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            }),
        builder: (result, {fetchMore, refetch}) {
          return DraggableScrollableSheet(
            controller: draggableScrollSheetController,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            snap: true,
            snapSizes: snapSizes,
            shouldCloseOnMinExtent: false,
            builder: (context, scrollController) {
              if (result.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              } else if (result.hasException) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.exclamationmark_triangle),
                  ),
                );
              }

              if (_itineraries == null || _itineraries!.isEmpty) {
                return Container();
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (!_itineraryChosen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_itineraries != null)
                                      Text(
                                        formatDuration(
                                            _itineraries![_bottomSheetIndex]
                                                .duration!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    if (_itineraryFares != null)
                                      Text(
                                          _itineraryFares![_bottomSheetIndex]!
                                                      .reduce((value,
                                                              element) =>
                                                          value + element) ==
                                                  0
                                              ? "Free"
                                              : "₱ ${_itineraryFares![_bottomSheetIndex]!.reduce((value, element) => value + element).toString()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary)),
                                  ],
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _chosenItineraries = [
                                          _itineraries![_bottomSheetIndex]
                                        ];
                                        _chosenItineraryFares = {
                                          0: _itineraryFares![
                                              _bottomSheetIndex]!
                                        };
                                        _chosenItineraryColors = {
                                          0: _itineraryColors![
                                              _bottomSheetIndex]!
                                        };
                                        _chosenItineraryLegRouteTypes = {
                                          0: _itineraryLegRouteTypes![
                                              _bottomSheetIndex]!
                                        };
                                        _center = LatLng(
                                            _itineraries![_bottomSheetIndex]
                                                .legs![0]
                                                .from!
                                                .lat,
                                            _itineraries![_bottomSheetIndex]
                                                .legs![0]
                                                .from!
                                                .lon);
                                        // _bounds = boundsFromLatLngList(
                                        //     decodePolyline(_itineraries![
                                        //                 _bottomSheetIndex]
                                        //             .legs![0]
                                        //             .legGeometry!
                                        //             .points!)
                                        //         .unpackPolyline());
                                        draggableScrollSheetController
                                            .jumpTo(minChildSize);
                                        _bottomSheetIndex = 0;
                                        _rebuildToChosen = true;
                                      });
                                    },
                                    child: const Text('Start')),
                              ],
                            ),
                            if (_itineraries != null)
                              _itineraries!.length > 1
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: DotsIndicator(
                                        dotsCount: _itineraries!.length,
                                        position: _bottomSheetIndex,
                                      ),
                                    )
                                  : Container(),
                          ],
                        ),
                      ),
                    if (!_itineraryChosen)
                      Padding(
                        padding: _itineraries!.length > 1
                            ? const EdgeInsets.only(top: 124)
                            : const EdgeInsets.only(top: 96),
                        child: PageView.builder(
                          // controller: scrollController,
                          controller: pageContoller,
                          onPageChanged: (index) {
                            setState(() {
                              _bottomSheetIndex = index;
                            });
                          },
                          itemCount: _itineraries!.length,
                          itemBuilder: (context, index) {
                            return ItineraryPage(
                              itinerary: _itineraries![index],
                              fares: _itineraryFares![index]!,
                              color: _itineraryColors![index]!,
                              legRouteTypes: _itineraryLegRouteTypes![index]!,
                              scrollController: scrollController,
                            );
                          },
                        ),
                      ),
                    if (_itineraryChosen)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _bottomSheetIndex = 0;
                                          _chosenItineraries = null;
                                          _chosenItineraryFares = null;
                                          _chosenItineraryColors = null;
                                          _chosenItineraryLegRouteTypes = null;
                                          _itineraryChosen = false;
                                          _rebuildToItineraries = true;

                                          // _refetchRequested = true;
                                        });
                                      },
                                      icon: const Icon(CupertinoIcons.back)),
                                  if (_bottomSheetIndex ==
                                      _chosenItineraries![0].legs!.length - 1)
                                    ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // Future.delayed(
                                              //     const Duration(seconds: 2),
                                              //     () {
                                              //   Navigator.pop(context);
                                              //   Navigator.pop(context);
                                              // });

                                              return AlertDialog(
                                                title: Text(
                                                  'Trip Complete!',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary),
                                                ),
                                                // content: const Text(
                                                //     'Thank you for using PARA!'),
                                                actions: [
                                                  OutlinedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty.all<
                                                                  Color>(Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Home',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelMedium!
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                  )))
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Finish')),
                                ],
                              ),
                              _chosenItineraries![0].legs!.length > 1
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: DotsIndicator(
                                        dotsCount:
                                            _chosenItineraries![0].legs!.length,
                                        position: _bottomSheetIndex,
                                      ),
                                    )
                                  : Container(),
                            ],
                          )),
                    if (_itineraryChosen)
                      Padding(
                          padding: const EdgeInsets.only(top: 72),
                          child: _buildLegPageWidget(
                              _chosenItineraries![0],
                              _chosenItineraryFares![0]!,
                              _chosenItineraryColors![0]!,
                              _chosenItineraryLegRouteTypes![0]!)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegPageWidget(ItineraryModel itinerary, List<double> fares,
      Color color, List<String> legRouteTypes) {
    return PageView.builder(
      itemCount: itinerary.legs!.length,
      onPageChanged: (value) {
        setState(() {
          _bottomSheetIndex = value;
          _center = LatLng(itinerary.legs![value].from!.lat,
              itinerary.legs![value].from!.lon);
          _bounds = boundsFromLatLngList(
              decodePolyline(itinerary.legs![value].legGeometry!.points!)
                  .unpackPolyline());
          _recenter = true;
        });
      },
      itemBuilder: (context, index) {
        return Center(
          child: LegTile(
              leg: itinerary.legs![index],
              fare: fares[index],
              legColor: color,
              routeType: legRouteTypes[index]),
        );
      },
    );
  }
}

class ItineraryPage extends StatelessWidget {
  final ItineraryModel itinerary;
  final List<double> fares;
  final Color color;
  final List<String> legRouteTypes;
  final ScrollController scrollController;

  const ItineraryPage({
    super.key,
    required this.itinerary,
    required this.fares,
    required this.color,
    required this.legRouteTypes,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: itinerary.legs!.length,
      itemBuilder: (context, index) {
        return LegTile(
            leg: itinerary.legs![index],
            fare: fares[index],
            legColor: color,
            routeType: legRouteTypes[index]);
      },
    );
  }
}

class LegTile extends StatelessWidget {
  final Leg leg;
  final double fare;
  final Color legColor;
  final String routeType;

  const LegTile(
      {super.key,
      required this.leg,
      required this.fare,
      required this.legColor,
      required this.routeType});

  @override
  Widget build(BuildContext context) {
    String mode = leg.mode!;
    if (leg.mode != 'WALK') {
      mode = routeTypeToReadable(getRouteType(leg.route!.gtfsId!));
    }

    String duration = formatDuration(leg.duration!.toInt());

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ListTile(
        minVerticalPadding: 8.0,
        minLeadingWidth: 48,
        leading: Container(
          height: 108,
          width: 48,
          decoration: BoxDecoration(
            color: legColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: Icon(
            leg.mode == 'WALK' ? Icons.directions_walk : Icons.directions_bus,
            color: getContrastingGrey(legColor),
          ),
        ),
        subtitle: Container(
          alignment: Alignment.centerLeft,
          height: 108,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leg.mode == 'WALK' && leg.from!.name == "Origin")
                Text(
                  'Walk towards ${leg.to?.name}',
                  // overflow: TextOverflow.ellipsis,
                ),
              if (leg.mode == 'WALK' && leg.from!.name != "Origin")
                Text(
                  'Walk from ${leg.from!.name} to ${leg.to!.name}',
                  // overflow: TextOverflow.ellipsis,
                ),
              if (leg.mode != 'WALK')
                Text(
                  'Ride ${leg.route!.shortName} $mode',
                  // overflow: TextOverflow.ellipsis,
                ),
              if (leg.mode != 'WALK')
                Text(
                  'Board at ${leg.from!.name}',
                  // overflow: TextOverflow.ellipsis,
                ),
              if (leg.mode != 'WALK')
                Text(
                  'Alight at ${leg.to!.name}',
                  // overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        trailing: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leg.mode != 'WALK')
                Text(
                  '₱ $fare',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                )
              else
                const SizedBox(height: 20),
              Text(
                duration,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class LegPage extends StatelessWidget {
//   final ItineraryModel itinerary;
//   final List<double> fares;
//   final Color color;
//   final List<String> legRouteTypes;

//   const LegPage(
//       {super.key,
//       required this.itinerary,
//       required this.fares,
//       required this.color,
//       required this.legRouteTypes});

//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       itemCount: itinerary.legs!.length,
//       itemBuilder: (context, index) {
//         return Center(
//           child: LegTile(
//               leg: itinerary.legs![index],
//               fare: fares[index],
//               legColor: color,
//               routeType: legRouteTypes[index]),
//         );
//       },
//     );
//   }
// }
