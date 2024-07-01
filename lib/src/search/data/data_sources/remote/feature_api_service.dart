import 'package:dio/dio.dart';
import 'package:para_client/core/constants/constants.dart';
import 'package:para_client/src/search/data/models/feature.dart';
import 'package:retrofit/retrofit.dart';

part 'feature_api_service.g.dart';

@RestApi(baseUrl: featureAPIBaseURL)
abstract class FeatureApiService {
  factory FeatureApiService(Dio dio, {String baseUrl}) = _FeatureApiService;

  @GET("api/")
  Future<HttpResponse<List<FeatureModel>>> getFeatures({
    @Query("q") required String q,
    @Query("lat") required double lat,
    @Query("lon") required double lon,
    @Query("limit") required int limit,
  });

  @GET("reverse")
  Future<HttpResponse<List<FeatureModel>>> reverseGeocode({
    @Query("lat") required double lat,
    @Query("lon") required double lon,
  });
}
