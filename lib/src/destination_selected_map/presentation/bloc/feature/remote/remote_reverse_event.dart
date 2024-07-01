import 'package:equatable/equatable.dart';

abstract class RemoteReverseEvent extends Equatable {
  const RemoteReverseEvent();

  @override
  List<Object> get props => [];
}

class GetReverseFeatures extends RemoteReverseEvent {
  final double lat;
  final double lon;

  const GetReverseFeatures({
    required this.lat,
    required this.lon,
  });

  @override
  List<Object> get props => [lat, lon];
}
