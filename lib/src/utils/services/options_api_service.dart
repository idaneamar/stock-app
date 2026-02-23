import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/api_client.dart';

/// Service for all Iron Condor options API calls.
class OptionsApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------------

  /// Fetch the latest (or most-recent) recommendations.
  Future<OptionsRecsResponse> getRecommendations({String? date}) async {
    try {
      final path =
          date != null
              ? '/options/recommendations/$date'
              : '/options/recommendations';
      final res = await _client.dio.get(path);
      return OptionsRecsResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('getRecommendations error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  /// List dates that have recommendation files.
  Future<List<String>> getAvailableDates({int limit = 90}) async {
    try {
      final res = await _client.dio.get(
        '/options/recommendations/dates',
        queryParameters: {'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      return ((data['dates'] as List?) ?? []).map((e) => e.toString()).toList();
    } on DioException catch (e) {
      log('getAvailableDates error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Status & symbols
  // ---------------------------------------------------------------------------

  Future<OptionsStatus> getStatus() async {
    try {
      final res = await _client.dio.get('/options/status');
      return OptionsStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('getOptionsStatus error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<List<String>> getSymbols() async {
    try {
      final res = await _client.dio.get('/options/symbols');
      final data = res.data as Map<String, dynamic>;
      return ((data['symbols'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();
    } on DioException catch (e) {
      log('getSymbols error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Execute (IBKR)
  // ---------------------------------------------------------------------------

  /// Execute selected recommendations via exeopt → IBKR.
  Future<Map<String, dynamic>> executeRecommendations({
    String? recDate,
    List<String>? tickers,
    bool dryRun = false,
  }) async {
    try {
      final payload = <String, dynamic>{
        'dry_run': dryRun,
        if (recDate != null) 'rec_date': recDate,
        if (tickers != null) 'tickers': tickers,
      };
      final res = await _client.dio.post('/options/execute', data: payload);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('executeRecommendations error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // AI Chat
  // ---------------------------------------------------------------------------

  Future<String> chatWithAI({
    required List<Map<String, dynamic>> messages,
    List<OptionsRecommendation> recommendations = const [],
    String? recDate,
    double? portfolioSize,
    bool includeBacktestHistory = true,
  }) async {
    try {
      final payload = <String, dynamic>{
        'messages': messages,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'include_backtest_history': includeBacktestHistory,
        if (recDate != null) 'rec_date': recDate,
        if (portfolioSize != null) 'portfolio_size': portfolioSize,
      };
      final res = await _client.dio.post('/options/ai/chat', data: payload);
      final data = res.data as Map<String, dynamic>;
      return (data['reply'] as String?) ?? '';
    } on DioException catch (e) {
      log('optionsAIChat error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Manual triggers
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> triggerFetchSymbols() async {
    try {
      final res = await _client.dio.post('/options/trigger/fetch-symbols');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerFetchSymbols error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> triggerPrefetch({
    List<int>? years,
    int workers = 4,
  }) async {
    try {
      final res = await _client.dio.post(
        '/options/trigger/prefetch',
        data: {if (years != null) 'years': years, 'workers': workers},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerPrefetch error: ${e.message}');
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> triggerRunOptsp({
    String? runDate,
    bool cacheOnly = true,
  }) async {
    try {
      final res = await _client.dio.post(
        '/options/trigger/run-optsp',
        data: {
          if (runDate != null) 'run_date': runDate,
          'cache_only': cacheOnly,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerRunOptsp error: ${e.message}');
      throw _client.handleError(e);
    }
  }
}
