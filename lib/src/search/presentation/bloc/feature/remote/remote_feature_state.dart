import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

// abstract class RemoteFeatureState extends Equatable {
//   final List<Feature>? features;
//   final DioException? error;

//   const RemoteFeatureState({this.features, this.error});

//   @override
//   List<Object?> get props => [features, error];
// }

// class RemoteFeaturesLoading extends RemoteFeatureState {
//   const RemoteFeaturesLoading();
// }

// class RemoteFeaturesSuccess extends RemoteFeatureState {
//   const RemoteFeaturesSuccess(List<Feature> features)
//       : super(features: features);
// }

// class RemoteFeaturesError extends RemoteFeatureState {
//   const RemoteFeaturesError(DioException error) : super(error: error);
// }

abstract class RemoteFeatureState extends Equatable {
  const RemoteFeatureState();

  @override
  List<Object?> get props => [];
}

class RemoteFeaturesLoading extends RemoteFeatureState {}

class RemoteFeaturesSuccess extends RemoteFeatureState {
  final List<Feature> features;

  const RemoteFeaturesSuccess(this.features);

  @override
  List<Object?> get props => [features];
}

class RemoteFeaturesError extends RemoteFeatureState {
  const RemoteFeaturesError(DioException error) : super();
}
