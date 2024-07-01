import 'package:bloc/bloc.dart';
import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/src/search/domain/usecases/get_feature.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_event.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_state.dart';

// class RemoteFeatureBloc extends Bloc<RemoteFeatureEvent, RemoteFeatureState> {
//   final GetFeatureUseCase _getFeatureUseCase;

//   RemoteFeatureBloc(this._getFeatureUseCase) : super(RemoteFeaturesLoading()) {
//     on<GetRemoteFeatures>(onGetFeatures);
//   }

//   Future<void> onGetFeatures(
//       GetRemoteFeatures event, Emitter<RemoteFeatureState> emit) async {
//     final dataState = await _getFeatureUseCase.call();

//     if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
//       emit(RemoteFeaturesSuccess(dataState.data!));
//     }

//     if (dataState is DataError) {
//       emit(RemoteFeaturesError(dataState.error!));
//     }
//   }
// }

class RemoteFeatureBloc extends Bloc<RemoteFeatureEvent, RemoteFeatureState> {
  final GetFeatureUseCase _getFeaturesUseCase;

  RemoteFeatureBloc(this._getFeaturesUseCase) : super(RemoteFeaturesLoading()) {
    on<GetRemoteFeatures>((event, emit) async {
      emit(RemoteFeaturesLoading());

      final params = GetFeaturesParams(
        q: event.q,
        lat: event.lat,
        lon: event.lon,
        limit: event.limit,
      );

      final dataState = await _getFeaturesUseCase.call(params: params);

      if (dataState is DataSuccess) {
        emit(RemoteFeaturesSuccess(dataState.data!));
      } else if (dataState is DataError) {
        print(dataState.error!);
        emit(RemoteFeaturesError(dataState.error!));
      }
    });
  }
}
