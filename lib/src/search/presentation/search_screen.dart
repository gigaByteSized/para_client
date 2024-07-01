import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/src/destination_selected_map/presentation/choose_on_map.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_bloc.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_event.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_state.dart';
import 'package:para_client/src/search/presentation/widgets/result_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.mode = 'search',
    this.initialQuery,
    this.initialCenter,
  });

  final String? mode;
  final String? initialQuery;

  final LatLng? initialCenter;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchControl = TextEditingController();
  final searchFocus = FocusNode();
  final LatLng _defaultLocation =
      const LatLng(14.1656, 121.2413); // UPLB Coordinates

  bool _initialLoad = true;

  Position? _currentLocation;
  bool locationLoading = true;

  LatLng? _initialCenter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocus.requestFocus();
    });

    getLastKnownLocation().then(
      (value) {
        setState(() {
          _currentLocation = value as Position;
          locationLoading = false;
        });
        return value;
      },
    );

    if (widget.initialQuery != null) {
      searchControl.text = widget.initialQuery!;
      _initialLoad = false;
      BlocProvider.of<RemoteFeatureBloc>(context).add(
        GetRemoteFeatures(
          q: widget.initialQuery!,
          lat: _currentLocation?.latitude ?? _defaultLocation.latitude,
          lon: _currentLocation?.longitude ?? _defaultLocation.longitude,
          limit: 10,
        ),
      );
    }

    if (widget.mode == 'loc-picker') {
      _initialCenter = widget.initialCenter ??
          LatLng(_currentLocation?.latitude ?? _defaultLocation.latitude,
              _currentLocation?.longitude ?? _defaultLocation.longitude);
    }

    // Initially load some data if necessary
    // BlocProvider.of<RemoteFeatureBloc>(context).add(GetRemoteFeatures(
    //   q: 'initial_query',
    //   lat: 37.7749,
    //   lon: -122.4194,
    //   limit: 10,
    // ));
  }

  @override
  void dispose() {
    searchControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: searchControl,
                focusNode: searchFocus,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                decoration: InputDecoration(
                  hintText: 'Search for a destination',
                  hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  EasyDebounce.debounce(
                    'searchDebounce',
                    const Duration(milliseconds: 500),
                    () {
                      if (_initialLoad) {
                        setState(() {
                          _initialLoad = false;
                        });
                      }
                      BlocProvider.of<RemoteFeatureBloc>(context).add(
                        GetRemoteFeatures(
                          q: value,
                          lat: _currentLocation?.latitude ??
                              _defaultLocation.latitude,
                          lon: _currentLocation?.longitude ??
                              _defaultLocation.longitude,
                          limit: 10,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body:

          // widget.mode == 'loc-picker'
          //     ? SafeArea(
          //         child: Stack(
          //         alignment: Alignment.center,
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Column(
          //               children: [
          //                 ListTile(
          //                   title: const Text('Current Location'),
          //                   onTap: () {
          //                     Navigator.pop(
          //                         context,
          //                         LatLng(_currentLocation!.latitude,
          //                             _currentLocation!.longitude));
          //                   },
          //                 ),
          //                 ListTile(
          //                   title: const Text('Choose on Map'),
          //                   onTap: () {
          //                     // Navigate to fake leaflet map
          //                     // Navigator.pop(context, null);
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
          //             child: _buildBody(_initialLoad),
          //           ),
          //         ],
          //       ))
          //     :

          SafeArea(child: _buildBody(_initialLoad)),
    );
  }

  Widget _buildBody(initial) {
    return BlocBuilder<RemoteFeatureBloc, RemoteFeatureState>(
      builder: (_, state) {
        if (widget.mode == 'loc-picker' && initial) {
          return ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('Current Location'),
                  onTap: () {
                    Navigator.pop(
                        context,
                        LatLng(_currentLocation!.latitude,
                            _currentLocation!.longitude));
                  },
                );
              } else if (index == 1) {
                return ListTile(
                  title: const Text('Choose on Map'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (widget.initialQuery != null) {
                        return ChooseOnMap(
                          destination: LatLng(_initialCenter!.latitude,
                              _initialCenter!.longitude),
                          // destination: null,
                          mode: 'destination',
                        );
                      } else {
                        return ChooseOnMap(
                          origin: LatLng(_initialCenter!.latitude,
                              _initialCenter!.longitude),
                          // origin: null,
                          mode: 'origin',
                        );
                      }
                    })).then((value) {
                      if (value != null) {
                        Navigator.pop(context, value);
                      }
                    });
                    // Navigate to fake leaflet map
                    // Navigator.pop(context, null);
                  },
                );
              }
              return const SizedBox();
            },
          );
        }

        if (state is RemoteFeaturesLoading && !initial) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is RemoteFeaturesError) {
          return const Center(
            child: Icon(CupertinoIcons.refresh),
          );
        } else if (state is RemoteFeaturesSuccess) {
          return ListView.builder(
            itemCount: widget.mode == "loc-picker"
                ? state.features.length + 2
                : state.features.length,
            itemBuilder: (context, index) {
              if (index == 0 && widget.mode == "loc-picker") {
                return ListTile(
                  title: const Text('Current Location'),
                  onTap: () {
                    Navigator.pop(
                        context,
                        LatLng(_currentLocation!.latitude,
                            _currentLocation!.longitude));
                  },
                );
              } else if (index == 1 && widget.mode == "loc-picker") {
                return ListTile(
                  title: const Text('Choose on Map'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (widget.initialQuery != null) {
                        return ChooseOnMap(
                          destination: LatLng(_initialCenter!.latitude,
                              _initialCenter!.longitude),
                          // destination: null,
                          mode: 'destination',
                        );
                      } else {
                        return ChooseOnMap(
                          origin: LatLng(_initialCenter!.latitude,
                              _initialCenter!.longitude),
                          // origin: null,
                          mode: 'origin',
                        );
                      }
                    })).then((value) {
                      if (value != null) {
                        Navigator.pop(context, value);
                      }
                    });
                    // Navigate to fake leaflet map
                    // Navigator.pop(context, null);
                  },
                );
              }

              return ResultTile(
                  feature: state
                      .features[index - (widget.mode == "loc-picker" ? 2 : 0)],
                  onFeaturePressed: (feature) {
                    if (widget.mode == 'loc-picker') {
                      Navigator.pop(context, feature);

                      return;
                    }

                    if (widget.mode == 'para_root') {
                      Navigator.pop(context, feature);
                      return;
                    }

                    if (widget.mode == 'search') {
                      Navigator.pop(context, feature);
                      return;
                    }

                    // Navigator.popAndPushNamed(context, '/mapView', arguments: {
                    //   'destination': LatLng(feature.geometry!.coordinates![1],
                    //       feature.geometry!.coordinates![0]),
                    //   'feature': feature
                    // });

                    // Navigate to destination selected map
                    // Navigator.pushNamed(context, '/destination-selected-map',
                    //     arguments: {
                    //       'origin': LatLng(_currentLocation!.latitude,
                    //           _currentLocation!.longitude),
                    //       'destination': feature.geometry.coordinates,
                    //       'mode': 'search'
                    //     });

                    //     (feature) => {
                    //   print("widget.mode: ${widget.mode}"),
                    //   if (widget.mode == 'loc-picker')
                    //     {
                    //       Navigator.pop(
                    //           context,
                    //           LatLng(feature.geometry!.coordinates![1],
                    //               feature.geometry!.coordinates![0]))

                    //     },
                    //   if (widget.mode == 'para_root')
                    //     Navigator.pop(context, feature),
                    //   // Navigator.popAndPushNamed(context, '/mapView', arguments: {
                    //   //   'destination': LatLng(feature.geometry!.coordinates![1],
                    //   //       feature.geometry!.coordinates![0]),
                    //   //   'feature': feature
                    //   // }),
                    // },
                  });
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
