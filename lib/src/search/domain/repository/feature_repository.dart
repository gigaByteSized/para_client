import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

abstract class FeatureRepository {
  Future<DataState<List<Feature>>> getFeatures({
    required String q,
    required double lat,
    required double lon,
    required int limit,
  });

  Future<DataState<List<Feature>>> reverseGeocode({
    required double lat,
    required double lon,
  });
}
