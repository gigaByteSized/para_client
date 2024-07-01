import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/core/usecase/usecase.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';
import 'package:para_client/src/search/domain/repository/feature_repository.dart';

class ReverseGeocodeUseCase
    extends UseCase<DataState<List<Feature>>, ReverseGeocodeParams> {
  final FeatureRepository _featureRepository;

  ReverseGeocodeUseCase(this._featureRepository);

  @override
  Future<DataState<List<Feature>>> call({ReverseGeocodeParams? params}) {
    return _featureRepository.reverseGeocode(
      lat: params!.lat,
      lon: params.lon,
    );
  }
}

class ReverseGeocodeParams {
  final double lat;
  final double lon;

  ReverseGeocodeParams({
    required this.lat,
    required this.lon,
  });
}
