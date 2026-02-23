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
      await _service.triggerRunOptsp(cacheOnly: true);
      // Poll until we get fresh recommendations (up to 5 minutes)
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 10));
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
      generateMessage.value = 'optsp finished — no recommendations for today';
      generateState.value = OptionsLoadState.success;
      await fetchMorningStatus();
    } catch (e) {
      generateMessage.value = e.toString();
      generateState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
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
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value = OptionsLoadState.success;
      return result['ok'] == true;
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
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value = OptionsLoadState.success;
      return result['ok'] == true;
    } catch (e) {
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return false;
    }
  }
}
