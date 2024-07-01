import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_bloc.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_event.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_state.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

class PlanTrip extends StatefulWidget {
  const PlanTrip({super.key});

  @override
  State<PlanTrip> createState() => _PlanTripState();
}

class _PlanTripState extends State<PlanTrip> {
  final controller = TextEditingController();
  final controllerOrigin = TextEditingController();
  final controllerDestination = TextEditingController();
  final pageContoller = PageController();
  final draggableScrollSheetController = DraggableScrollableController();

  LatLng? origin;
  LatLng? destination;

  bool loaded = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  FareClasses? fareClass = FareClasses.regular;

  String reverseMode = 'destination';

  Feature? feature;

  @override
  void initState() {
    super.initState();

    controllerOrigin.text = 'Your location';
    getLastKnownLocation().then(
      (value) {
        setState(() {
          LatLng latLng = LatLng(value!.latitude, value.longitude);
          origin = latLng;
          loaded = true;
        });

        return value;
      },
    );

    controllerDestination.text = 'Choose destination';

    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Plan a trip',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        body: BlocListener<RemoteReverseBloc, RemoteReverseState>(
          listener: (context, state) {
            if (state is RemoteReverseSuccess && state.features.isNotEmpty) {
              if (state.features[0].properties!.name != null) {
                controller.text = state.features[0].properties!.name!;
                if (reverseMode == 'destination') {
                  controllerDestination.text =
                      state.features[0].properties!.name!;
                  setState(() {
                    destination = LatLng(
                      state.features[0].geometry!.coordinates![1],
                      state.features[0].geometry!.coordinates![0],
                    );
                  });
                } else {
                  controllerOrigin.text = state.features[0].properties!.name!;
                  setState(() {
                    origin = LatLng(
                      state.features[0].geometry!.coordinates![1],
                      state.features[0].geometry!.coordinates![0],
                    );
                  });
                }
              }
            }
          },
          child: BlocBuilder<RemoteReverseBloc, RemoteReverseState>(
            builder: (context, state) {
              // if (state is RemoteReverseLoading) {
              //   return const Center(
              //     child: CupertinoActivityIndicator(),
              //   );
              // } else if (state is RemoteReverseError) {
              //   return const Center(
              //     child: Icon(CupertinoIcons.refresh),
              //   );
              // }

              if (!loaded) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: controllerOrigin,
                                  style: textTheme.displaySmall?.copyWith(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/search',
                                        arguments: {
                                          'mode': 'loc-picker',
                                          'initialCenter': origin,
                                        }).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          if (value.runtimeType == LatLng) {
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
                                                value
                                                    .geometry!.coordinates![0]);
                                            controllerOrigin.text =
                                                value.properties!.name!;
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: controllerDestination,
                                  style: textTheme.displaySmall?.copyWith(
                                    fontSize: 14,
                                    color: controllerDestination.text !=
                                            'Choose destination'
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/search',
                                        arguments: {
                                          'mode': 'loc-picker',
                                          'initialQuery':
                                              controllerDestination.text !=
                                                      'Choose destination'
                                                  ? controllerDestination.text
                                                  : '',
                                          'initialCenter': origin,
                                        }).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          if (value.runtimeType == LatLng) {
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
                                                value
                                                    .geometry!.coordinates![0]);
                                            controllerDestination.text =
                                                value.properties!.name!;
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Fare class",
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
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
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            if (origin != null && destination != null) {
                              Navigator.pushNamed(context, '/mapView',
                                  arguments: {
                                    'origin': origin,
                                    'destination': destination,
                                    'feature': feature,
                                    'time': selectedTime,
                                    'fareClass': fareClass
                                  });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select origin and destination'),
                                ),
                              );
                            }
                          },
                          child: const Text('Plan trip'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
