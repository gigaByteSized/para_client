import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/location_service.dart'; // Make sure to implement this service to get location

class FakeLeafletMap extends StatefulWidget {
  const FakeLeafletMap({super.key, this.origin, this.destination, this.mode});

  final LatLng? origin;
  final LatLng? destination;
  final String? mode;

  @override
  State<FakeLeafletMap> createState() => _FakeLeafletMapState();
}

class _FakeLeafletMapState extends State<FakeLeafletMap> {
  LatLng? _initialCenter;
  LatLng? returnLocation;

  bool tapped = false;

  @override
  void initState() {
    super.initState();
    // Timer.run(() {
    //   try {
    //     InternetAddress.lookup('google.com').then((result) {
    //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //         print('connected');
    //       } else {
    //         _showDialog(); // show dialog
    //       }
    //     }).catchError((error) {
    //       _showDialog(); // show dialog
    //     });
    //   } on SocketException catch (_) {
    //     _showDialog();
    //     print('not connected'); // show dialog
    //   }
    // });

    if (widget.origin == null || widget.destination == null) {
      getLastKnownLocation().then(
        (value) {
          if (value != null) {
            setState(() {
              _initialCenter = LatLng(value.latitude, value.longitude);
            });
          } else {
            getCurrentLocation().then(
              (value) {
                setState(() {
                  _initialCenter = LatLng(value.latitude, value.longitude);
                });
              },
            );
          }
        },
      );
    }
  }

  // void _showDialog() {
  //   // dialog implementation
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(right: 16.0),
  //             child: Icon(CupertinoIcons.exclamationmark_triangle_fill,
  //                 color: Theme.of(context).colorScheme.primary),
  //           ),
  //           const Text('Error!'),
  //         ],
  //       ),
  //       content: const Text("Internet connection is required."),
  //       actions: <Widget>[
  //         ElevatedButton(
  //             child: const Text("Exit"),
  //             onPressed: () {
  //               exit(0);
  //             })
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_initialCenter == null && widget.destination == null) {
      return const Center(child: CircularProgressIndicator());
    }

    LatLng center = widget.origin ??
        widget.destination ??
        _initialCenter ??
        const LatLng(14.5995, 120.9842);

    return Stack(
      children: [
        if (widget.destination != null || widget.origin != null)
          Center(
            child: Icon(
              Icons.location_on,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
        if (widget.destination != null || widget.origin != null)
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              maxZoom: 21.0,
              minZoom: 8.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  returnLocation = position.center;
                });
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
              ),
            ),
            children: [
              TileLayer(
                // retinaMode: true,
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.jratienza.para_client",
              ),
            ],
          )
        else
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 8.0,
              onTap: (tapPosition, point) {
                // Navigator.pushNamed(context, '/mapView',
                //     arguments: {'destination': point})

                // SchedulerBinding.instance.addPostFrameCallback((_) {
                //   Navigator.pushNamed(context, '/mapView',
                //       arguments: {'destination': point});
                // })

                if (!tapped) {
                  setState(() {
                    tapped = true;
                  });
                  // Navigator.pushNamed(context, '/mapView',
                  //     arguments: {'destination': point});
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      tapped = false;
                    });
                    Navigator.pushNamed(context, '/mapView',
                        arguments: {'destination': point});
                  });
                }
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
              ),
            ),
            children: [
              TileLayer(
                // retinaMode: true,
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.jratienza.para_client",
              ),
            ],
          ),
      ],
    );
  }
}
