import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_bloc.dart';
import 'package:para_client/src/search/data/data_sources/remote/feature_api_service.dart';
import 'package:para_client/src/search/data/repository/feature_repository.dart';
import 'package:para_client/src/search/domain/repository/feature_repository.dart';
import 'package:para_client/src/search/domain/usecases/get_feature.dart';
import 'package:para_client/src/search/domain/usecases/reverse_geocode.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<FeatureApiService>(FeatureApiService(sl()));

  sl.registerSingleton<FeatureRepository>(FeatureRepositoryImpl(sl()));

  // Use Cases
  sl.registerFactory<GetFeatureUseCase>(() => GetFeatureUseCase(sl()));
  sl.registerFactory<ReverseGeocodeUseCase>(() => ReverseGeocodeUseCase(sl()));

  // Blocs
  sl.registerFactory<RemoteFeatureBloc>(() => RemoteFeatureBloc(sl()));
  sl.registerFactory<RemoteReverseBloc>(() => RemoteReverseBloc(sl()));
}
