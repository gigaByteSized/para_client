import 'package:bloc/bloc.dart';
import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_event.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_state.dart';
import 'package:para_client/src/search/domain/usecases/reverse_geocode.dart';

// class RemoteReverseBloc extends Bloc<RemoteReverseEvent, RemoteReversetate> {
//   final GetFeatureUseCase _getFeatureUseCase;

//   RemoteReverseBloc(this._getFeatureUseCase) : super(RemoteReverseLoading()) {
//     on<GetRemoteReverse>(onGetReverse);
//   }

//   Future<void> onGetReverse(
//       GetRemoteReverse event, Emitter<RemoteReversetate> emit) async {
//     final dataState = await _getFeatureUseCase.call();

//     if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
//       emit(RemoteReverseSuccess(dataState.data!));
//     }

//     if (dataState is DataError) {
//       emit(RemoteReverseError(dataState.error!));
//     }
//   }
// }

class RemoteReverseBloc extends Bloc<RemoteReverseEvent, RemoteReverseState> {
  final ReverseGeocodeUseCase _getReverseUseCase;

  RemoteReverseBloc(this._getReverseUseCase) : super(RemoteReverseLoading()) {
    on<GetReverseFeatures>((event, emit) async {
      emit(RemoteReverseLoading());

      final params = ReverseGeocodeParams(
        lat: event.lat,
        lon: event.lon,
      );

      final dataState = await _getReverseUseCase.call(params: params);

      if (dataState is DataSuccess) {
        emit(RemoteReverseSuccess(dataState.data!));
      } else if (dataState is DataError) {
        emit(RemoteReverseError(dataState.error!));
      }
    });
  }
}
