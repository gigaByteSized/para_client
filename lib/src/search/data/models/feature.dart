import 'package:para_client/src/search/domain/entities/feature.dart';

class FeatureModel extends Feature {
  const FeatureModel({
    GeometryModel? super.geometry,
    super.type,
    PropertiesModel? super.properties,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> map) {
    return FeatureModel(
      geometry: map['geometry'] != null
          ? GeometryModel.fromJson(map['geometry'])
          : null,
      type: map['type'],
      properties: map['properties'] != null
          ? PropertiesModel.fromJson(map['properties'])
          : null,
    );
  }
}

class GeometryModel extends Geometry {
  const GeometryModel({
    List<double>? super.coordinates,
    super.type,
  });

  factory GeometryModel.fromJson(Map<String, dynamic> map) {
    return GeometryModel(
      coordinates: map['coordinates'] != null
          ? List<double>.from(map['coordinates'].map((x) => x.toDouble()))
          : null,
      type: map['type'],
    );
  }
}

class PropertiesModel extends Properties {
  const PropertiesModel({
    super.osmType,
    super.osmId,
    List<double>? super.extent,
    super.country,
    super.osmKey,
    super.city,
    super.countrycode,
    super.osmValue,
    super.name,
    super.state,
    super.type,
  });

  factory PropertiesModel.fromJson(Map<String, dynamic> map) {
    return PropertiesModel(
      osmType: map['osm_type'],
      osmId: map['osm_id'],
      extent: map['extent'] != null
          ? List<double>.from(map['extent'].map((x) => x.toDouble()))
          : null,
      country: map['country'],
      osmKey: map['osm_key'],
      city: map['city'],
      countrycode: map['countrycode'],
      osmValue: map['osm_value'],
      name: map['name'],
      state: map['state'],
      type: map['type'],
    );
  }
}
