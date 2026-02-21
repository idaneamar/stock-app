import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:stock_app/src/utils/services/api_client.dart';

class AnalysisService {
  final ApiClient _client = ApiClient();

  Future<Response> getAnalysisExcel(int scanId, {String? analysisType}) async {
    try {
      log('Requesting Excel file for scan ID: $scanId');
      final response = await _client.dio.get(
        "analysis/excel/$scanId",
        queryParameters:
            (analysisType == null || analysisType.isEmpty)
                ? null
                : {'analysis_type': analysisType},
        options: _client.excelOptions.copyWith(
          validateStatus: (status) {
            if (status == null) return false;
            return status == 404 || (status >= 200 && status < 300);
          },
        ),
      );
      log('Excel API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Excel API error: ${e.message}');
      if (e.response?.statusCode == 404 && e.response != null) {
        return e.response!;
      }
      throw _client.handleError(e);
    }
  }

  Future<Response> getScanTrades(int scanId, {String? analysisType}) async {
    try {
      return await _client.dio.get(
        "analysis/active-trades/$scanId",
        queryParameters:
            (analysisType == null || analysisType.isEmpty)
                ? null
                : {'analysis_type': analysisType},
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getCombinedActiveTradesExcel({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) async {
    try {
      log(
        'Requesting combined active trades Excel from $startDate to $endDate',
      );
      final response = await _client.dio.get(
        "analysis/combined/active-trades/excel",
        queryParameters: {
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
          'start_date': startDate,
          'end_date': endDate,
        },
        options: _client.excelOptions,
      );
      log('Combined Excel API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Combined Excel API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> getCombinedAnalysisExcel({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) async {
    try {
      log('Requesting combined analysis Excel from $startDate to $endDate');
      final response = await _client.dio.get(
        "analysis/combined/excel",
        queryParameters: {
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
          'start_date': startDate,
          'end_date': endDate,
        },
        options: _client.excelOptions,
      );
      log(
        'Combined Analysis Excel API response status: ${response.statusCode}',
      );
      return response;
    } on DioException catch (e) {
      log('Combined Analysis Excel API error: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception(
          'API Error: Endpoint not found. Please check if the combined analysis feature is available.',
        );
      }
      throw _client.handleError(e);
    }
  }

  Future<Response> getActiveTrades({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) async {
    try {
      return await _client.dio.get(
        "analysis/active-trades",
        queryParameters: {
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getTradesExcel({
    required int scanId,
    String? analysisType,
  }) async {
    try {
      log('Requesting trades Excel file for scan ID: $scanId');
      final response = await _client.dio.get(
        "analysis/active-trades/excel/$scanId",
        queryParameters:
            (analysisType == null || analysisType.isEmpty)
                ? null
                : {'analysis_type': analysisType},
        options: _client.excelOptions,
      );
      log('Trades Excel API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Trades Excel API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> updateActiveTrades({
    required int scanId,
    required List<Map<String, dynamic>> updates,
    String? analysisType,
  }) async {
    try {
      log('Updating active trades for scan ID: $scanId');
      final response = await _client.dio.patch(
        "analysis/active-trades/$scanId",
        queryParameters:
            (analysisType == null || analysisType.isEmpty)
                ? null
                : {'analysis_type': analysisType},
        data: {'updates': updates},
      );
      log('Update active trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Update active trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteActiveTrade({
    required int scanId,
    required String symbol,
    String? analysisType,
  }) async {
    try {
      log('Deleting active trade for scan ID: $scanId, symbol: $symbol');
      final response = await _client.dio.delete(
        "analysis/active-trades/$scanId",
        queryParameters: {
          'symbol': symbol,
          if (analysisType != null && analysisType.isNotEmpty)
            'analysis_type': analysisType,
        },
      );
      log('Delete active trade API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Delete active trade API error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
