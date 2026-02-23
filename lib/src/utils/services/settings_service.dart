import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:stock_app/src/utils/services/api_client.dart';

class SettingsService {
  final ApiClient _client = ApiClient();

  Future<Response> getSettings() async {
    try {
      return await _client.dio.get("settings/");
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> updateSettings({
    required double portfolioSize,
    bool? strictRules,
    bool? volumeSpikeRequired,
    bool? useIntraday,
    double? dailyLossLimitPct,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'portfolio_size': portfolioSize.round(),
        if (strictRules != null) 'strict_rules': strictRules,
        if (volumeSpikeRequired != null)
          'volume_spike_required': volumeSpikeRequired,
        if (useIntraday != null) 'use_intraday': useIntraday,
        if (dailyLossLimitPct != null)
          'daily_loss_limit_pct': dailyLossLimitPct,
      };

      log('PUT settings/ - Request data: $requestData');
      final response = await _client.dio.put(
        "settings/",
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      log(
        'PUT settings/ - Response: ${response.statusCode} - ${response.data}',
      );
      return response;
    } on DioException catch (e) {
      log(
        'PUT settings/ - DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw _client.handleError(e);
    }
  }

  Future<Response> resetAll() async {
    try {
      log('Requesting reset all data');
      final response = await _client.dio.post("settings/reset-all", data: '');
      log('Reset all API response status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      log('Reset all API error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
