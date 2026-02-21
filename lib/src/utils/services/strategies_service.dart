import 'package:dio/dio.dart';
import 'package:stock_app/src/utils/services/api_client.dart';

class StrategiesService {
  final ApiClient _client = ApiClient();

  Future<Response> getStrategies({bool enabledOnly = false}) async {
    try {
      return await _client.dio.get(
        'strategies/',
        queryParameters: enabledOnly ? {'enabled_only': true} : null,
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> createStrategy(Map<String, dynamic> payload) async {
    try {
      return await _client.dio.post('strategies/', data: payload);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> updateStrategy(int id, Map<String, dynamic> payload) async {
    try {
      return await _client.dio.put('strategies/$id', data: payload);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteStrategy(int id) async {
    try {
      return await _client.dio.delete('strategies/$id');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }
}
