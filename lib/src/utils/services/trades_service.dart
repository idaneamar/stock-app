import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:stock_app/src/utils/services/api_client.dart';

class TradesService {
  final ApiClient _client = ApiClient();

  Future<Response> getOpenTrades({
    required int page,
    required int pageSize,
  }) async {
    try {
      log('Requesting open trades - page: $page, pageSize: $pageSize');
      final response = await _client.dio.get(
        "trades/open",
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      log('Open trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Open trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> exportOpenTrades() async {
    try {
      log('Requesting export open trades');
      final response = await _client.dio.get("trades/open/export");
      log('Export open trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Export open trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> importOpenTrades(Map<String, dynamic> tradesData) async {
    try {
      log('Importing open trades');
      final response = await _client.dio.post("trades/open", data: tradesData);
      log('Import open trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Import open trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteOpenTrade(int tradeId) async {
    try {
      log('Deleting open trade with ID: $tradeId');
      final response = await _client.dio.delete("trades/open/$tradeId");
      log('Delete open trade API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Delete open trade API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> updateOpenTrade({
    required int tradeId,
    required String exitDate,
  }) async {
    try {
      log('Updating open trade with ID: $tradeId, exit date: $exitDate');
      final response = await _client.dio.patch(
        "trades/open/$tradeId",
        data: {'target_date': exitDate},
      );
      log('Update open trade API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Update open trade API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  // Closed Trades
  Future<Response> getClosedTrades({
    required int page,
    required int pageSize,
  }) async {
    try {
      log('Requesting closed trades - page: $page, pageSize: $pageSize');
      final response = await _client.dio.get(
        "trades/closed",
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      log('Closed trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Closed trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> exportClosedTrades() async {
    try {
      log('Requesting export closed trades');
      final response = await _client.dio.get("trades/closed/export");
      log('Export closed trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Export closed trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> importClosedTrades(List<dynamic> tradesData) async {
    try {
      log('Importing closed trades');
      final response = await _client.dio.post(
        "trades/closed",
        data: tradesData,
      );
      log('Import closed trades API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Import closed trades API error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
