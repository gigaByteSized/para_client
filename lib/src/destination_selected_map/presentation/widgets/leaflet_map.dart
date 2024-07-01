import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:info_popup/info_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/core/services/unpack_polyline.dart';
import 'package:para_client/src/alerts_module/domain/alert_model.dart';
import 'package:para_client/src/destination_selected_map/domain/graphql/itinerary_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to implement this service to get location

class LeafletMap extends StatefulWidget {
  const LeafletMap(
      {super.key,
      this.initCenter,
      this.initZoom,
      this.bounds,
      this.origin,
      this.destination,
      this.itineraries,
      this.itineraryColors,
      this.itineraryLegRouteTypes,
      this.alerts});

  final LatLng? initCenter;
  final double? initZoom;
  final LatLngBounds? bounds;
  final LatLng? origin;
  final LatLng? destination;
  final List<ItineraryModel>? itineraries;
  final Map<int, Color>? itineraryColors;
  final Map<int, List<String>>? itineraryLegRouteTypes;
  final List<Alert>? alerts;

  @override
  State<LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> {
  LatLng? _currentLocation;
  final LatLng _defaultLocation =
      const LatLng(14.1656, 121.2413); // UPLB Coordinates

  // List<String>? _legPolylineStrings;
  List<Polyline> _polylines = [];
  List<LatLng> _alertMartkerLatLngs = [];
  List<List<String>>? _itineraryLegPolylineStrings = [];
  List<List<String>>? _itineraryLegRouteTypes = [];
  // List<String>? _legRouteTypes = [];

  @override
  void initState() {
    super.initState();
    // _currentLocation = getCurrentLocation();

    Timer.run(() {
      try {
        InternetAddress.lookup('google.com').then((result) {
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          } else {
            _showDialog(); // show dialog
          }
        }).catchError((error) {
          _showDialog(); // show dialog
        });
      } on SocketException catch (_) {
        _showDialog();
      }
    });

    if (widget.destination == null) {
      Future.delayed(Duration.zero, () {
        getLastKnownLocation().then((value) {
          setState(() {
            _currentLocation = LatLng(value!.latitude, value.longitude);
          });
        });
      });
    }

    if (widget.itineraries != null && widget.itineraries!.isNotEmpty) {
      for (ItineraryModel itinerary in widget.itineraries!) {
        List<Geometry>? legGeometries =
            itinerary.legs!.map((leg) => leg.legGeometry!).toList();
        List<String> legPolylineStrings =
            legGeometries.map((geometry) => geometry.points!).toList();
        _itineraryLegPolylineStrings!.add(legPolylineStrings);
      }

      for (int index in widget.itineraryLegRouteTypes!.keys) {
        List<String> legRouteTypes = widget.itineraryLegRouteTypes![index]!;
        _itineraryLegRouteTypes!.add(legRouteTypes);
      }

      // _legPolylineStrings =
      //     legGeometries!.map((geometry) => geometry.points!).toList();

      // print(legGeometries);

      // List<Leg> legs = widget.itineraries!.map((itinerary) => itinerary.legs).reduce((value, element) => value + element);
      // _legRouteTypes = widget.itineraries!
      //     .map((itinerary) => itinerary.legs
      //         .map((leg) => leg.routeType)
      //         .reduce((value, element) => value + element))
      //     .toList();
    }

    if (widget.alerts != null && widget.alerts!.isNotEmpty) {
      for (Alert alert in widget.alerts!) {
        LatLng location =
            LatLng(alert.coordinates.latitude, alert.coordinates.longitude);

        _alertMartkerLatLngs.add(location);
      }
    }
  }

  void _showDialog() {
    // dialog implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(CupertinoIcons.exclamationmark_triangle_fill,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const Text('Error!'),
          ],
        ),
        content: const Text("Internet connection is required."),
        actions: <Widget>[
          ElevatedButton(
              child: const Text("Exit"),
              onPressed: () {
                exit(0);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        initialCenter: widget.initCenter ??
            widget.destination ??
            _currentLocation ??
            _defaultLocation,
        initialZoom: widget.initZoom ?? 15.0,
        maxZoom: 21.0,
        minZoom: 8.0,
        initialCameraFit: widget.bounds != null
            ? CameraFit.bounds(bounds: widget.bounds!)
            : null,
        interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom),
      ),
      children: [
        TileLayer(
          // retinaMode: true,
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.jratienza.para_client",
        ),
        // if (_legPolylineStrings != null)
        //   PolylineLayer(
        //     polylines: _legPolylineStrings!
        //         .map((polylineString) => Polyline(
        //             points: decodePolyline(polylineString).unpackPolyline(),
        //             strokeWidth: 6.0,
        //             color: Theme.of(context).colorScheme.secondary,
        //             isDotted: true))
        //         .toList(),
        //   ),
        if (_itineraryLegPolylineStrings != null)
          for (int i = 0; i < _itineraryLegPolylineStrings!.length; i++)
            PolylineLayer(
                // use map(value, iondex)
                polylines: _itineraryLegPolylineStrings![i]
                    .mapIndexed((index, polylineString) => Polyline(
                        points: decodePolyline(polylineString).unpackPolyline(),
                        strokeWidth: 6.0,
                        color: widget.itineraryColors!.length > 1
                            ? widget.itineraryColors![i]!
                            : widget.itineraryColors![0]!,
                        isDotted: _itineraryLegRouteTypes![i][index] == "WALK"))
                    .toList()), // add markers at the first point of each leg of each itinerary
        if (_itineraryLegPolylineStrings != null)
          for (int i = 0; i < _itineraryLegPolylineStrings!.length; i++)
            MarkerLayer(
                markers: _itineraryLegPolylineStrings![i]
                    .mapIndexed((index, polylineString) => Marker(
                        width: 30.0,
                        height: 30.0,
                        point: decodePolyline(polylineString)
                            .unpackPolyline()
                            .first,
                        child: Container(
                            decoration: BoxDecoration(
                              color: widget.itineraryColors!.length > 1
                                  ? widget.itineraryColors![i]!
                                  : widget.itineraryColors![0]!,
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
                              _itineraryLegRouteTypes![i][index] == "WALK"
                                  ? Icons.directions_walk
                                  : Icons.directions_bus,
                              // shadows: [
                              //   Shadow(
                              //     color: Colors.grey.withOpacity(0.5),
                              //     blurRadius: 4.0,
                              //     offset: const Offset(3.0, 3.0),
                              //   ),
                              // ],
                              size: 20.0,
                              color: getContrastingGrey(
                                  widget.itineraryColors!.length > 1
                                      ? widget.itineraryColors![i]!
                                      : widget.itineraryColors![0]!),
                            ))))
                    .toList()),
        if (_alertMartkerLatLngs.isNotEmpty)
          for (int i = 0; i < _alertMartkerLatLngs.length; i++)
            MarkerLayer(
              markers: [
                Marker(
                  width: 30.0,
                  height: 30.0,
                  point: _alertMartkerLatLngs[i],
                  child: InfoPopupWidget(
                    // contentTitle: widget.alerts![i].alertName,
                    arrowTheme: const InfoPopupArrowTheme(
                      color: Colors.white,
                    ),
                    customContent: () {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7.0,
                              offset: const Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.alerts![i].alertName,
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                              child: Text(widget.alerts![i].alertNotes!,
                                  style:
                                      Theme.of(context).textTheme.bodySmall!),
                            ),
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
                ),
              ],
            ),

        if (widget.destination != null && widget.origin != null)
          MarkerLayer(markers: [
            Marker(
              // alignment: Alignment.center,
              width: 30.0,
              height: 30.0,
              point: widget.origin!,
              child: Icon(
                Icons.radio_button_checked,
                shadows: [
                  Shadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 4.0,
                    offset: const Offset(3.0, 3.0),
                  ),
                ],
                size: 30.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Marker(
              // alignment: Alignment.bottomCenter,
              width: 50.0,
              height: 50.0,
              point: widget.destination!,
              child: Icon(
                Icons.location_pin,
                shadows: [
                  Shadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 4.0,
                    offset: const Offset(3.0, 3.0),
                  ),
                ],
                size: 50.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ]),
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 200),
        //   child: RichAttributionWidget(
        //     attributions: [
        //       TextSourceAttribution(
        //         'OpenStreetMap contributors',
        //         onTap: () => launchUrl(
        //             Uri.parse('https://openstreetmap.org/copyright')),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
