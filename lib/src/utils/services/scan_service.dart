import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:stock_app/src/utils/services/api_client.dart';

class ScanService {
  final ApiClient _client = ApiClient();

  Future<Response> scanStocks({
    required double maxMarketCap,
    bool ignoreVix = false,
    required double minAvgTransactionValue,
    required double minAvgVolume,
    required double minMarketCap,
    required double minPrice,
    required double minVolatility,
    required double topNStocks,
    String? programId,
    bool strictRules = true,
    double? adxMin,
    bool? volumeSpikeRequired,
    double? dailyLossLimitPct,
    bool allowIntradayPrices = false,
  }) async {
    try {
      final payload = <String, dynamic>{
        "max_market_cap": maxMarketCap,
        "ignore_vix": ignoreVix,
        "min_avg_transaction_value": minAvgTransactionValue,
        "min_avg_volume": minAvgVolume,
        "min_market_cap": minMarketCap,
        "min_price": minPrice,
        "min_volatility": minVolatility,
        "top_n_stocks": topNStocks,
        "strict_rules": strictRules,
        if (adxMin != null) "adx_min": adxMin,
        if (volumeSpikeRequired != null)
          "volume_spike_required": volumeSpikeRequired,
        if (dailyLossLimitPct != null)
          "daily_loss_limit_pct": dailyLossLimitPct,
        "allow_intraday_prices": allowIntradayPrices,
      };
      if (programId != null && programId.isNotEmpty) {
        payload["program_id"] = programId;
      }
      log('POST /scans payload (exact JSON): ${jsonEncode(payload)}');
      final response = await _client.dio.post("scans/", data: payload);
      return response;
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getScans({int page = 1, int pageSize = 10}) async {
    try {
      return await _client.dio.get("scans/?page=$page&page_size=$pageSize");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getScanById(int scanId) async {
    try {
      return await _client.dio.get("scans/$scanId");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteScan(int scanId) async {
    try {
      return await _client.dio.delete("scans/$scanId");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteAllScans() async {
    try {
      return await _client.dio.delete("scans/");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getCompletedScans({
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _client.dio.get(
        "scans/completed/filtered?start_date=$startDate&end_date=$endDate",
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getScanDateRange() async {
    try {
      return await _client.dio.get("scans/dates/range");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> getAllScannedStocksExcel(String scanId) async {
    try {
      log('Requesting all scanned stocks Excel file');
      final response = await _client.dio.get(
        "scans/$scanId/stocks/excel",
        options: _client.excelOptions,
      );
      log(
        'All scanned stocks Excel API response status: ${response.statusCode}',
      );
      return response;
    } on DioException catch (e) {
      log('All scanned stocks Excel API error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Response> restartAnalysis(int scanId) async {
    try {
      log('Requesting restart analysis for scan ID: $scanId');
      final response = await _client.dio.post(
        "scans/$scanId/restart-analysis",
        data: '',
      );
      log('Restart analysis API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Restart analysis API error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
