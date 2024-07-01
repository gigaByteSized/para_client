import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/src/destination_selected_map/domain/graphql/itinerary_model.dart';

export 'itinerary_helpers.dart';

// Pop itinerary if its only leg is a walking leg
List<ItineraryModel> cleanItineraries(List<ItineraryModel> itineraries) {
  // If there is only one itinerary, return it
  if (itineraries.length == 1) return itineraries;

  // If there are multiple itineraries, check if there is an itinerary with only one leg
  List<ItineraryModel> temp = itineraries;

  for (int i = 0; i < temp.length; i++) {
    if (temp[i].legs!.length == 1) {
      if (temp[i].legs![0].mode == "WALK") {
        temp.removeAt(i);
        break;
      }
    }
  }

  return temp;
}

enum FareClasses { regular, discounted }

Map<int, List<double>> computeFares(
  List<ItineraryModel> itineraries,
  List<Map<String, dynamic>> fareData,
  FareClasses fareClass,
) {
  Map<int, List<double>> faresPerItinerary = {};
  String fc = fareClass.toString().split(".")[1].toLowerCase();
  String baseFareKey = "base_fare_$fc";
  String succeedingFareKey = "succeeding_$fc";

  for (int i = 0; i < itineraries.length; i++) {
    List<double> fares = [];
    for (int j = 0; j < itineraries[i].legs!.length; j++) {
      double fare = 0;
      if (itineraries[i].legs![j].mode! == "WALK") {
        fares.add(0);
        continue;
      }

      String routeType;
      String routeId = itineraries[i].legs![j].route!.gtfsId!.split(":")[1];
      routeType = getRouteType(routeId);

      for (int k = 0; k < fareData.length; k++) {
        if (fareData[k]["route_type"] == routeType) {
          dynamic baseFare = fareData[k][baseFareKey];
          dynamic succeedingFare = fareData[k][succeedingFareKey];

          dynamic minDistance = fareData[k]["minimum_distance"];
          dynamic distance = itineraries[i].legs![j].distance! / 1000;

          if (distance <= minDistance) {
            fare += baseFare;
          } else {
            double excessDistance = distance - minDistance;
            double excessFare = excessDistance * succeedingFare;
            fare += (baseFare + excessFare);
          }
        }
      }
      fares.add(fare.ceilToDouble());
    }
    faresPerItinerary[i] = fares;
  }

  return faresPerItinerary;
}

List<ItineraryModel> sortByDuration(List<ItineraryModel> itinerary) {
  itinerary.sort((a, b) => a.duration!.compareTo(b.duration!));
  return itinerary;
}

// helper
List<String> routeTypes = [
  "PUJ",
  "MPUJ",
  "PUB",
  "PUV",
  "TRIKE",
];

String getRouteType(String routeId) {
  for (int i = 0; i < routeTypes.length; i++) {
    if (routeId.contains(routeTypes[i])) {
      return routeTypes[i];
    }
  }
  return "UNKNOWN";
}

String routeTypeToReadable(String routeType) {
  switch (routeType) {
    case "PUJ":
      return "Jeep";
    case "MPUJ":
      return "Modern Jeep";
    case "PUB":
      return "Bus";
    case "PUV":
      return "Van";
    case "TRIKE":
      return "Tricycle";
    default:
      return "Unknown";
  }
}

Map<int, Color> generateItineraryColors(int itineraryCount) {
  Map<int, Color> itineraryColors = {};

  // Generate random colors for each itinerary based on the primary and secondary colors
  for (int i = 0; i < itineraryCount; i++) {
    while (true) {
      Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
      if (!itineraryColors.containsValue(color)) {
        itineraryColors[i] = color;
        break;
      }
    }
  }

  return itineraryColors;
}

Map<int, List<String>> generateLegRouteTypes(List<ItineraryModel> itineraries) {
  Map<int, List<String>> legRouteTypes = {};

  for (int i = 0; i < itineraries.length; i++) {
    List<String> routeTypes = [];
    for (int j = 0; j < itineraries[i].legs!.length; j++) {
      if (itineraries[i].legs![j].mode == "WALK") {
        routeTypes.add("WALK");
        continue;
      }

      String routeId = itineraries[i].legs![j].route!.gtfsId!.split(":")[1];
      routeTypes.add(getRouteType(routeId));
    }
    legRouteTypes[i] = routeTypes;
  }

  return legRouteTypes;
}

String formatDistance(double distance) {
  if (distance < 1000) {
    return "${distance.toStringAsFixed(0)}m";
  } else {
    return "${(distance / 1000).toStringAsFixed(2)}km";
  }
}

Color getContrastingGrey(Color backgroundColor) {
  // Calculate the luminance of the background color
  double luminance = backgroundColor.computeLuminance();
  // Return a darker grey for light backgrounds and a lighter grey for dark backgrounds
  if (luminance > 0.7) {
    return Colors.grey[900]!;
  } else {
    return Colors.grey[200]!;
  }
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  double offset = 0.0025;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1!) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1!) y1 = latLng.longitude;
      if (latLng.longitude < y0!) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(
    LatLng(x0! - offset, y0! - offset),
    LatLng(x1! + offset, y1! + offset),
  );
}

String twelveToTwentyFourHour(TimeOfDay time) {
  String hour = time.hour.toString();
  String minute = time.minute.toString();
  if (time.hour < 10) {
    hour = "0$hour";
  }
  if (time.minute < 10) {
    minute = "0$minute";
  }
  return "$hour:$minute";
}
