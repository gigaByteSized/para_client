import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

// abstract class RemoteReverseState extends Equatable {
//   final List<Feature>? features;
//   final DioException? error;

//   const RemoteReverseState({this.features, this.error});

//   @override
//   List<Object?> get props => [features, error];
// }

// class RemoteReverseLoading extends RemoteReverseState {
//   const RemoteReverseLoading();
// }

// class RemoteReverseSuccess extends RemoteReverseState {
//   const RemoteReverseSuccess(List<Feature> features)
//       : super(features: features);
// }

// class RemoteReverseError extends RemoteReverseState {
//   const RemoteReverseError(DioException error) : super(error: error);
// }

abstract class RemoteReverseState extends Equatable {
  const RemoteReverseState();

  @override
  List<Object?> get props => [];
}

class RemoteReverseLoading extends RemoteReverseState {}

class RemoteReverseSuccess extends RemoteReverseState {
  final List<Feature> features;

  const RemoteReverseSuccess(this.features);

  @override
  List<Object?> get props => [features];
}

class RemoteReverseError extends RemoteReverseState {
  const RemoteReverseError(DioException error) : super();
}
