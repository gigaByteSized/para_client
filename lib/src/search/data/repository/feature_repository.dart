import 'dart:io';

import 'package:dio/dio.dart';
import 'package:para_client/core/resources/data_state.dart';
import 'package:para_client/src/search/data/data_sources/remote/feature_api_service.dart';
import 'package:para_client/src/search/data/models/feature.dart';
import 'package:para_client/src/search/domain/repository/feature_repository.dart';

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureApiService _featureApiService;

  FeatureRepositoryImpl(this._featureApiService);

  @override
  Future<DataState<List<FeatureModel>>> getFeatures({
    required String q,
    required double lat,
    required double lon,
    required int limit,
  }) async {
    try {
      final httpResponse = await _featureApiService.getFeatures(
        q: q,
        lat: lat,
        lon: lon,
        limit: limit,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataError(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<List<FeatureModel>>> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    try {
      final httpResponse = await _featureApiService.reverseGeocode(
        lat: lat,
        lon: lon,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataError(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataError(e);
    }
  }
}
