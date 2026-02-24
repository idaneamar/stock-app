import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

/// Dio client that always points at the local options server.
///
/// The base URL is read once from SharedPreferences (default: http://localhost:8001/).
/// Call [OptionsApiService.resetClient] after the user changes the URL in Settings
/// so the next request picks up the new value.
class OptionsApiService {
  // ── in-memory cache of the Dio instance ────────────────────────────────────
  static Dio? _dio;
  static String? _loadedUrl;

  /// Returns the cached Dio, creating a new one if the URL has changed.
  static Future<Dio> _client() async {
    final url = await SharedPrefsService.getOptionsServerUrl();
    if (_dio == null || _loadedUrl != url) {
      _loadedUrl = url;
      _dio = Dio(
        BaseOptions(
          baseUrl: url,
          // Quick connection timeout so "server offline" fails fast
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(minutes: 5),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    }
    return _dio!;
  }

  /// Call this after the user saves a new server URL in Settings.
  static void resetClient() {
    _dio = null;
    _loadedUrl = null;
  }

  /// Returns the URL that will be used for the next request.
  static Future<String> currentUrl() =>
      SharedPrefsService.getOptionsServerUrl();

  // ── Error helper ───────────────────────────────────────────────────────────
  Exception _handle(DioException e) {
    final msg = e.response?.data ?? e.message ?? 'Unknown error';
    final code = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception(
        'Options server offline. '
        'Run: python run_options_server.py',
      );
    }
    if (code != null) return Exception('API Error: Status $code - $msg');
    return Exception('API Error: $msg');
  }

  // ---------------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------------

  Future<OptionsRecsResponse> getRecommendations({String? date}) async {
    try {
      final path =
          date != null
              ? '/options/recommendations/$date'
              : '/options/recommendations';
      final res = await (await _client()).get(path);
      return OptionsRecsResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('getRecommendations error: ${e.message}');
      throw _handle(e);
    }
  }

  Future<List<String>> getAvailableDates({int limit = 90}) async {
    try {
      final res = await (await _client()).get(
        '/options/recommendations/dates',
        queryParameters: {'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      return ((data['dates'] as List?) ?? []).map((e) => e.toString()).toList();
    } on DioException catch (e) {
      log('getAvailableDates error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Status & symbols
  // ---------------------------------------------------------------------------

  Future<OptionsStatus> getStatus() async {
    try {
      final res = await (await _client()).get('/options/status');
      return OptionsStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('getOptionsStatus error: ${e.message}');
      throw _handle(e);
    }
  }

  Future<List<String>> getSymbols() async {
    try {
      final res = await (await _client()).get('/options/symbols');
      final data = res.data as Map<String, dynamic>;
      return ((data['symbols'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();
    } on DioException catch (e) {
      log('getSymbols error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Execute (IBKR)
  // ---------------------------------------------------------------------------

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
      final res = await (await _client()).post(
        '/options/execute',
        data: payload,
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('executeRecommendations error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Delete recommendations
  // ---------------------------------------------------------------------------

  /// Delete all recommendations for a date (removes the CSV file on the server).
  Future<void> deleteRecommendationDate(String date) async {
    try {
      await (await _client()).delete('/options/recommendations/$date');
    } on DioException catch (e) {
      log('deleteRecommendationDate error: ${e.message}');
      throw _handle(e);
    }
  }

  /// Remove a single ticker from a date's recommendation file.
  Future<void> deleteRecommendationTicker(String date, String ticker) async {
    try {
      await (await _client()).delete(
        '/options/recommendations/$date/${ticker.toUpperCase()}',
      );
    } on DioException catch (e) {
      log('deleteRecommendationTicker error: ${e.message}');
      throw _handle(e);
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
      final res = await (await _client()).post(
        '/options/ai/chat',
        data: payload,
      );
      final data = res.data as Map<String, dynamic>;
      return (data['reply'] as String?) ?? '';
    } on DioException catch (e) {
      log('optionsAIChat error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Job logs
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getJobLogs({int limit = 50}) async {
    try {
      final res = await (await _client()).get(
        '/options/job-logs',
        queryParameters: {'limit': limit},
      );
      final data = res.data as Map<String, dynamic>;
      return ((data['logs'] as List?) ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      log('getJobLogs error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // AI data endpoints
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getTickerHistory(
    String ticker, {
    int startYear = 2023,
    int? endYear,
  }) async {
    try {
      final params = <String, dynamic>{'start_year': startYear};
      if (endYear != null) params['end_year'] = endYear;
      final res = await (await _client()).get(
        '/options/ai/ticker-history/${ticker.toUpperCase()}',
        queryParameters: params,
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('getTickerHistory error: ${e.message}');
      throw _handle(e);
    }
  }

  Future<Map<String, dynamic>> getDataCoverage() async {
    try {
      final res = await (await _client()).get('/options/ai/data-coverage');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('getDataCoverage error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Morning status & SP500 diff
  // ---------------------------------------------------------------------------

  /// One-stop morning briefing: last prefetch, last SP500 update, last optsp.
  Future<Map<String, dynamic>> getMorningStatus() async {
    try {
      final res = await (await _client()).get('/options/morning-status');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('getMorningStatus error: ${e.message}');
      throw _handle(e);
    }
  }

  /// Latest S&P 500 symbol change diff (added / removed tickers).
  Future<Map<String, dynamic>> getSp500Diff() async {
    try {
      final res = await (await _client()).get('/options/sp500-diff');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('getSp500Diff error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Manual triggers
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> triggerFetchSymbols() async {
    try {
      final res = await (await _client()).post(
        '/options/trigger/fetch-symbols',
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerFetchSymbols error: ${e.message}');
      throw _handle(e);
    }
  }

  Future<Map<String, dynamic>> triggerPrefetch({
    List<int>? years,
    int workers = 4,
  }) async {
    try {
      final res = await (await _client()).post(
        '/options/trigger/prefetch',
        data: {if (years != null) 'years': years, 'workers': workers},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerPrefetch error: ${e.message}');
      throw _handle(e);
    }
  }

  /// Cancel a running script (optsp.py | prefetch_options_datasp.py | fetch_sp500_symbols.py).
  Future<Map<String, dynamic>> cancelScript({
    String script = 'optsp.py',
  }) async {
    try {
      final res = await (await _client()).post(
        '/options/cancel',
        queryParameters: {'script': script},
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('cancelScript error: ${e.message}');
      throw _handle(e);
    }
  }

  Future<Map<String, dynamic>> triggerRunOptsp({
    String? runDate,
    bool cacheOnly = true,
  }) async {
    try {
      final res = await (await _client()).post(
        '/options/trigger/run-optsp',
        data: {
          if (runDate != null) 'run_date': runDate,
          'cache_only': cacheOnly,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('triggerRunOptsp error: ${e.message}');
      throw _handle(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Health / connectivity check
  // ---------------------------------------------------------------------------

  /// Returns true if the local options server is reachable.
  Future<bool> checkHealth() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: await SharedPrefsService.getOptionsServerUrl(),
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final res = await dio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
