import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:info_popup/info_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/src/alerts_module/domain/alert_model.dart'; // Make sure to implement this service to get location

class AlertMapView extends StatefulWidget {
  const AlertMapView({super.key, this.alert});

  final Alert? alert;

  @override
  State<AlertMapView> createState() => _AlertMapViewState();
}

class _AlertMapViewState extends State<AlertMapView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(widget.alert!.coordinates.latitude,
                widget.alert!.coordinates.longitude),
            initialZoom: 15.0,
            maxZoom: 18.0,
            minZoom: 8.0,
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
            MarkerLayer(markers: [
              Marker(
                width: 30.0,
                height: 30.0,
                point: LatLng(widget.alert!.coordinates.latitude,
                    widget.alert!.coordinates.longitude),
                child: InfoPopupWidget(
                  // contentTitle: widget.alerts![i].alertName,
                  customContent: () {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.alert!.alertName,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.alert!.alertNotes!,
                              style: Theme.of(context).textTheme.bodySmall!),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 4.0,
                          offset: const Offset(3.0, 3.0),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.warning,
                      size: 20.0,
                      color: getContrastingGrey(
                          Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              )
            ])
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
