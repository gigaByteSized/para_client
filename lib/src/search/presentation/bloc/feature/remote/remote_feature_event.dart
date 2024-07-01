import 'package:equatable/equatable.dart';

abstract class RemoteFeatureEvent extends Equatable {
  const RemoteFeatureEvent();

  @override
  List<Object> get props => [];
}

class GetRemoteFeatures extends RemoteFeatureEvent {
  final String q;
  final double lat;
  final double lon;
  final int limit;

  const GetRemoteFeatures({
    required this.q,
    required this.lat,
    required this.lon,
    required this.limit,
  });

  @override
  List<Object> get props => [q, lat, lon, limit];
}
