import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:stock_app/src/utils/services/api_client.dart';

class OrderService {
  final ApiClient _client = ApiClient();

  Future<Response> placeOrder({
    required int scanId,
    String? analysisType,
  }) async {
    try {
      log('Requesting place order for scan ID: $scanId');
      final response = await _client.dio.post(
        "analysis/orders/place-order",
        queryParameters: {
          'scan_id': scanId,
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
        },
        data: '',
      );
      log('Place order API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Place order API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> getOrderPreview({
    required int scanId,
    String? analysisType,
  }) async {
    try {
      log('Requesting order preview for scan ID: $scanId');
      final response = await _client.dio.get(
        "analysis/orders/preview/$scanId",
        queryParameters:
            (analysisType == null || analysisType.isEmpty)
                ? null
                : {'analysis_type': analysisType},
      );
      log('Order preview API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Order preview API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> placeModifiedOrders({
    required int scanId,
    required List<Map<String, dynamic>> modifiedOrders,
    String? analysisType,
  }) async {
    try {
      log('Placing modified orders for scan ID: $scanId');
      final response = await _client.dio.post(
        "analysis/orders/place-modified-orders",
        data: {
          'scan_id': scanId,
          'modified_orders': modifiedOrders,
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
        },
      );
      log('Place modified orders API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Place modified orders API error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
