import 'package:equatable/equatable.dart';

class Feature extends Equatable {
  final Geometry? geometry;
  final String? type;
  final Properties? properties;

  const Feature({
    this.geometry,
    this.type,
    this.properties,
  });

  @override
  List<Object?> get props => [geometry, type, properties];
}

class Geometry extends Equatable {
  final List<dynamic>? coordinates;
  final String? type;

  const Geometry({this.coordinates, this.type});

  @override
  List<Object?> get props => [coordinates, type];
}

class Properties extends Equatable {
  final String? osmType;
  final int? osmId;
  final List<dynamic>? extent;
  final String? country;
  final String? osmKey;
  final String? city;
  final String? countrycode;
  final String? osmValue;
  final String? name;
  final String? state;
  final String? type;

  const Properties({
    this.osmType,
    this.osmId,
    this.extent,
    this.country,
    this.osmKey,
    this.city,
    this.countrycode,
    this.osmValue,
    this.name,
    this.state,
    this.type,
  });

  @override
  List<Object?> get props => [
        osmType,
        osmId,
        extent,
        country,
        osmKey,
        city,
        countrycode,
        osmValue,
        name,
        state,
        type,
      ];
}
