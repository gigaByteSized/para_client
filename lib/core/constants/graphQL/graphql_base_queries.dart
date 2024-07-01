export 'package:graphql_flutter/graphql_flutter.dart';

const String getItinerariesQuery = r'''
query GetItineraries($fromLat: Float!, $fromLon: Float!, $toLat: Float!, $toLon: Float!, $date: String!, $time: String!, $transportModes: [TransportMode!]!) {
  plan(
    from: {lat: $fromLat, lon: $fromLon}
    to: {lat: $toLat, lon: $toLon}
    date: $date
    time: $time
    transportModes: $transportModes
  ) {
    itineraries {
      startTime
      endTime
      duration
      legs {
        mode
        from {
          name
          lat
          lon
        }
        to {
          name
          lat
          lon
        }
        route {
          gtfsId
          longName
          shortName
        }
        duration
        distance
        legGeometry {
          points
        }
      }
    }
  }
}
''';
