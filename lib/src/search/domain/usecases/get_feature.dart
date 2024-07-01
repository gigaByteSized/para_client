import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/core/usecase/usecase.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';
import 'package:para_client/src/search/domain/repository/feature_repository.dart';

// class GetFeatureUseCase implements UseCase<DataState<List<Feature>>, void> {
//   final FeatureRepository _featureRepository;

//   GetFeatureUseCase(this._featureRepository);

//   @override
//   Future<DataState<List<Feature>>> call({void params}) {
//     return _featureRepository.getFeatures();
//   }
// }
// import 'package:para_client/core/resources/data_state.dart';
// import 'package:para_client/src/search/domain/entities/feature.dart';
// import 'package:para_client/src/search/domain/repository/feature_repository.dart';

class GetFeatureUseCase
    extends UseCase<DataState<List<Feature>>, GetFeaturesParams> {
  final FeatureRepository _featureRepository;

  GetFeatureUseCase(this._featureRepository);

  @override
  Future<DataState<List<Feature>>> call({GetFeaturesParams? params}) {
    return _featureRepository.getFeatures(
      q: params!.q,
      lat: params.lat,
      lon: params.lon,
      limit: params.limit,
    );
  }
}

class GetFeaturesParams {
  final String q;
  final double lat;
  final double lon;
  final int limit;

  GetFeaturesParams({
    required this.q,
    required this.lat,
    required this.lon,
    required this.limit,
  });
}
