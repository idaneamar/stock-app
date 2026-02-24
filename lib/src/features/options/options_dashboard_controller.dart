import 'package:get/get.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

enum OptionsLoadState { idle, loading, success, error, offline }

class OptionsDashboardController extends GetxController {
  final OptionsApiService _service = OptionsApiService();

  final Rx<OptionsLoadState> loadState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> statusState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> executeState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> generateState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> morningState = OptionsLoadState.idle.obs;

  final RxList<OptionsRecommendation> recommendations =
      <OptionsRecommendation>[].obs;
  final Rxn<OptionsStatus> status = Rxn<OptionsStatus>();
  final RxString currentDate = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString executeMessage = ''.obs;
  final RxString generateMessage = ''.obs;
  final RxString serverUrl = ''.obs;
  final RxString currentJobId = ''.obs;

  /// Morning briefing data (last prefetch, sp500 update, etc.)
  final Rxn<Map<String, dynamic>> morningStatus = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _loadServerUrl();
    fetchRecommendations();
    fetchStatus();
    fetchMorningStatus();
  }

  Future<void> _loadServerUrl() async {
    serverUrl.value = await SharedPrefsService.getOptionsServerUrl();
  }

  bool _isOffline(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('offline') ||
        msg.contains('connection') ||
        msg.contains('timed out') ||
        msg.contains('refused') ||
        msg.contains('network');
  }

  // ---------------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------------

  Future<void> fetchRecommendations({String? date}) async {
    loadState.value = OptionsLoadState.loading;
    errorMessage.value = '';
    try {
      final result = await _service.getRecommendations(date: date);
      recommendations.assignAll(result.recommendations);
      currentDate.value = result.date ?? '';
      loadState.value = OptionsLoadState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      loadState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Generate recommendations (manual — button click)
  // ---------------------------------------------------------------------------

  Future<void> generateRecommendations() async {
    if (generateState.value == OptionsLoadState.loading) return;
    generateState.value = OptionsLoadState.loading;
    generateMessage.value = 'Running optsp — this may take a few minutes…';
    try {
      final start = await _service.triggerRunOptsp(cacheOnly: true);
      if (start['already_running'] == true) {
        generateMessage.value =
            'optsp is already running — open Activity to view';
        generateState.value = OptionsLoadState.success;
        await fetchMorningStatus();
        return;
      }
      currentJobId.value = (start['job_id'] as String?) ?? '';

      // Poll every 5s for up to 10 min: prefer job logs (truth), then refresh recs.
      for (int i = 0; i < 120; i++) {
        await Future.delayed(const Duration(seconds: 5));
        if (generateState.value != OptionsLoadState.loading)
          return; // cancelled

        // Pull recent job logs and look for our job id.
        final logs = await _service.getJobLogs(limit: 60);
        final jobId = currentJobId.value;
        final entry =
            jobId.isEmpty
                ? null
                : logs.cast<Map<String, dynamic>>().firstWhere(
                  (e) => (e['id']?.toString() ?? '') == jobId,
                  orElse: () => <String, dynamic>{},
                );

        if (entry != null && entry.isNotEmpty) {
          final status = (entry['status']?.toString() ?? '').toLowerCase();
          if (status.isNotEmpty && status != 'running') {
            final ok = entry['ok'] == true;
            final summary = (entry['summary']?.toString() ?? '').trim();
            generateMessage.value =
                ok
                    ? (summary.isNotEmpty
                        ? summary
                        : 'Recommendations generated')
                    : (summary.isNotEmpty
                        ? summary
                        : 'optsp failed — open Activity for details');

            // Refresh morning status + recs when done (even on failure).
            await fetchMorningStatus();
            await fetchRecommendations();
            generateState.value =
                ok ? OptionsLoadState.success : OptionsLoadState.error;
            return;
          }
        }

        // Fallback: if recommendations already exist for today, show them.
        final result = await _service.getRecommendations();
        if (result.recommendations.isNotEmpty) {
          recommendations.assignAll(result.recommendations);
          currentDate.value = result.date ?? '';
          generateMessage.value =
              '${result.recommendations.length} recommendations ready';
          generateState.value = OptionsLoadState.success;
          await fetchMorningStatus();
          return;
        }
      }

      generateMessage.value =
          'Timed out waiting for optsp — open Activity to see logs';
      generateState.value = OptionsLoadState.error;
      await fetchMorningStatus();
    } catch (e) {
      if (generateState.value == OptionsLoadState.idle) return; // cancelled
      generateMessage.value = e.toString();
      generateState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  Future<void> cancelGenerating() async {
    if (generateState.value != OptionsLoadState.loading) return;
    generateState.value = OptionsLoadState.idle;
    generateMessage.value = '';
    try {
      await _service.cancelScript(script: 'optsp.py');
    } catch (_) {}
    await fetchMorningStatus();
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  Future<void> fetchStatus() async {
    statusState.value = OptionsLoadState.loading;
    try {
      final s = await _service.getStatus();
      status.value = s;
      statusState.value = OptionsLoadState.success;
    } catch (e) {
      statusState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Morning status
  // ---------------------------------------------------------------------------

  Future<void> fetchMorningStatus() async {
    morningState.value = OptionsLoadState.loading;
    try {
      final data = await _service.getMorningStatus();
      morningStatus.value = data;
      morningState.value = OptionsLoadState.success;
    } catch (e) {
      morningState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  @override
  void refresh() {
    _loadServerUrl();
    fetchRecommendations();
    fetchStatus();
    fetchMorningStatus();
  }

  // ---------------------------------------------------------------------------
  // Execute (IBKR)
  // ---------------------------------------------------------------------------

  Future<bool> executeAll({bool dryRun = false}) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        dryRun: dryRun,
      );
      final ok = result['ok'] == true;
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value =
          ok ? OptionsLoadState.success : OptionsLoadState.error;
      return ok;
    } catch (e) {
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return false;
    }
  }

  Future<bool> executeSingle(
    OptionsRecommendation rec, {
    bool dryRun = false,
  }) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        tickers: [rec.ticker],
        dryRun: dryRun,
      );
      final ok = result['ok'] == true;
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value =
          ok ? OptionsLoadState.success : OptionsLoadState.error;
      return ok;
    } catch (e) {
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return false;
    }
  }
}
