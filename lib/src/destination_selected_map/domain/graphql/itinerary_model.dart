import 'package:equatable/equatable.dart';

class ItineraryModel extends Equatable {
  final int? startTime;
  final int? endTime;
  final int? duration;
  final List<Leg>? legs;

  const ItineraryModel({
    this.startTime,
    this.endTime,
    this.duration,
    this.legs,
  });

  @override
  List<Object?> get props => [startTime, endTime, duration, legs];

  static ItineraryModel fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      startTime: map['startTime'],
      endTime: map['endTime'],
      duration: map['duration'],
      legs: List<Leg>.from(map['legs'].map((x) => Leg.fromMap(x))),
    );
  }
}

class Leg extends Equatable {
  final String? mode;
  final LocDescription? from;
  final LocDescription? to;
  final Route? route;
  final double? duration;
  final double? distance;
  final Geometry? legGeometry;

  const Leg({
    this.mode,
    this.from,
    this.to,
    this.route,
    this.duration,
    this.distance,
    this.legGeometry,
  });

  @override
  List<Object?> get props => [mode, from, to, route, legGeometry];

  static Leg fromMap(Map<String, dynamic> map) {
    return Leg(
      mode: map['mode'],
      from: LocDescription(
        name: map['from']['name'],
        lat: map['from']['lat'],
        lon: map['from']['lon'],
      ),
      to: LocDescription(
        name: map['to']['name'],
        lat: map['to']['lat'],
        lon: map['to']['lon'],
      ),
      route: Route.fromMap(map['route'] ?? {}),
      duration: map['duration'],
      distance: map['distance'],
      legGeometry: Geometry.fromMap(map['legGeometry']),
    );
  }
}

class LocDescription extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const LocDescription({
    required this.name,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [name, lat, lon];
}

class Route extends Equatable {
  final String? gtfsId;
  final String? shortName;
  final String? longName;

  const Route({
    this.gtfsId,
    this.shortName,
    this.longName,
  });

  @override
  List<Object?> get props => [gtfsId, shortName, longName];

  static Route fromMap(Map<String, dynamic> map) {
    return Route(
      gtfsId: map['gtfsId'],
      shortName: map['shortName'],
      longName: map['longName'],
    );
  }
}

class Geometry extends Equatable {
  final int? length;
  final String? points;

  const Geometry({
    this.length,
    this.points,
  });

  @override
  List<Object?> get props => [length, points];

  static Geometry fromMap(Map<String, dynamic> map) {
    return Geometry(
      length: map['length'],
      points: map['points'],
    );
  }
}
