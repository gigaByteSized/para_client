import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ChooseOnMap extends StatefulWidget {
  const ChooseOnMap({super.key, this.origin, this.destination, this.mode});

  final LatLng? origin;
  final LatLng? destination;
  final String? mode;

  @override
  State<ChooseOnMap> createState() => _ChooseOnMapState();
}

class _ChooseOnMapState extends State<ChooseOnMap> {
  LatLng? _initialCenter;
  LatLng? returnLocation;

  @override
  void initState() {
    super.initState();
    // if (widget.origin == null || widget.destination == null) {
    //   _currentLocation = getCurrentLocation();
    //   _currentLocation?.then((position) {
    //     setState(() {
    //       _initialCenter = LatLng(position.latitude, position.longitude);
    //     });
    //   });
    // }
    if (widget.mode == 'origin') {
      setState(() {
        _initialCenter = widget.origin;
      });
    } else {
      setState(() {
        _initialCenter = widget.destination;
      });
    }
  }

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
        Stack(
          children: [
            if (widget.destination != null || widget.origin != null)
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15.0,
                  maxZoom: 18.0,
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
                    retinaMode: true,
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                  onTap: (tapPosition, point) => {
                    Navigator.pushNamed(context, '/mapView',
                        arguments: {'destination': point})
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    retinaMode: true,
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: "com.jratienza.para_client",
                  ),
                ],
              ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, returnLocation);
                  },
                  child: const Text('Select Location'),
                ),
              ),
            ),
            if (widget.destination != null || widget.origin != null)
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.location_on,
                      size: 50,
                      color: widget.destination != null
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
