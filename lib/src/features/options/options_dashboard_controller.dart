import 'package:get/get.dart';
import 'package:stock_app/src/features/options/options_ibkr_log_sheet.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

enum OptionsLoadState { idle, loading, success, error, offline }

class OptionsConfig {
  final int ibkrPort;
  final int ibkrClientId;
  final bool dryRun;
  final double stopLossPct;
  final double takeProfitPct;
  final double portfolioSize;
  final List<int> prefetchYears;
  final int maxTrades;

  const OptionsConfig({
    this.ibkrPort = 7497,
    this.ibkrClientId = 1,
    this.dryRun = false,
    this.stopLossPct = 1.0,
    this.takeProfitPct = 0.5,
    this.portfolioSize = 250000.0,
    this.prefetchYears = const [],
    this.maxTrades = 10,
  });

  bool get isPaper => ibkrPort == 7497;
  bool get isTestMode => dryRun;
}

class OptionsDashboardController extends GetxController {
  final OptionsApiService _service = OptionsApiService();

  final Rx<OptionsLoadState> loadState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> statusState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> executeState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> generateState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> morningState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> prefetchState = OptionsLoadState.idle.obs;
  final RxString prefetchMessage = ''.obs;
  final Rx<OptionsLoadState> fetchSymbolsState = OptionsLoadState.idle.obs;
  final RxString fetchSymbolsMessage = ''.obs;

  final RxList<OptionsRecommendation> recommendations =
      <OptionsRecommendation>[].obs;
  final Rxn<OptionsStatus> status = Rxn<OptionsStatus>();
  final RxString currentDate = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString executeMessage = ''.obs;
  final RxString generateMessage = ''.obs;
  final RxString serverUrl = ''.obs;
  final RxString currentJobId = ''.obs;

  /// Last IBKR execution result — surfaced to the UI for the log sheet.
  final Rxn<IbkrExecutionResult> lastExecuteResult = Rxn<IbkrExecutionResult>();

  /// Morning briefing data (last prefetch, sp500 update, etc.)
  final Rxn<Map<String, dynamic>> morningStatus = Rxn<Map<String, dynamic>>();

  /// Active configuration (loaded from SharedPrefs on init and after config changes).
  final Rx<OptionsConfig> config = const OptionsConfig().obs;

  @override
  void onInit() {
    super.onInit();
    _loadServerUrl();
    _loadConfig();
    fetchRecommendations();
    fetchStatus();
    fetchMorningStatus();
  }

  Future<void> _loadServerUrl() async {
    serverUrl.value = await SharedPrefsService.getOptionsServerUrl();
  }

  // ---------------------------------------------------------------------------
  // Config
  // ---------------------------------------------------------------------------

  Future<void> _loadConfig() async {
    final port = await SharedPrefsService.getOptionsIbkrPort();
    final cid = await SharedPrefsService.getOptionsIbkrClientId();
    final dry = await SharedPrefsService.getOptionsDryRun();
    final sl = await SharedPrefsService.getOptionsStopLossPct();
    final tp = await SharedPrefsService.getOptionsTakeProfitPct();
    final ps = await SharedPrefsService.getOptionsPortfolioSize();
    final yr = await SharedPrefsService.getOptionsPrefetchYears();
    final mt = await SharedPrefsService.getOptionsMaxTrades();

    config.value = OptionsConfig(
      ibkrPort: port,
      ibkrClientId: cid,
      dryRun: dry,
      stopLossPct: sl,
      takeProfitPct: tp,
      portfolioSize: ps,
      prefetchYears: yr,
      maxTrades: mt,
    );
  }

  /// Reload config (call after the config panel is closed).
  Future<void> reloadConfig() => _loadConfig();

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
      final limit = config.value.maxTrades;
      final limited =
          limit > 0
              ? result.recommendations.take(limit).toList()
              : result.recommendations;
      recommendations.assignAll(limited);
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

    await _loadConfig();

    try {
      final start = await _service.triggerRunOptsp();
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
        if (generateState.value != OptionsLoadState.loading) {
          return; // cancelled
        }

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
          final st = (entry['status']?.toString() ?? '').toLowerCase();
          if (st.isNotEmpty && st != 'running') {
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
      await _service.cancelScript(script: 'opsp.py');
    } catch (_) {}
    await fetchMorningStatus();
  }

  // ---------------------------------------------------------------------------
  // Prefetch trigger
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // SP500 symbol fetch
  // ---------------------------------------------------------------------------

  Future<void> triggerFetchSymbols() async {
    if (fetchSymbolsState.value == OptionsLoadState.loading) return;
    fetchSymbolsState.value = OptionsLoadState.loading;
    fetchSymbolsMessage.value = 'Updating S&P 500 symbol list…';
    try {
      await _service.triggerFetchSymbols();
      fetchSymbolsMessage.value =
          'SP500 update started — refreshing in background';
      fetchSymbolsState.value = OptionsLoadState.success;
      await Future.delayed(const Duration(seconds: 3));
      await fetchMorningStatus();
      await fetchStatus();
    } catch (e) {
      fetchSymbolsMessage.value = e.toString();
      fetchSymbolsState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  Future<void> triggerPrefetch() async {
    if (prefetchState.value == OptionsLoadState.loading) return;
    prefetchState.value = OptionsLoadState.loading;
    prefetchMessage.value = 'ThetaData prefetch started…';

    await _loadConfig();
    final cfg = config.value;

    try {
      await _service.triggerPrefetch(
        years: cfg.prefetchYears.isNotEmpty ? cfg.prefetchYears : null,
      );
      prefetchMessage.value = 'Prefetch running in background — check Activity';
      prefetchState.value = OptionsLoadState.success;
    } catch (e) {
      prefetchMessage.value = e.toString();
      prefetchState.value =
          _isOffline(e) ? OptionsLoadState.offline : OptionsLoadState.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Risk summary (computed from loaded recommendations)
  // ---------------------------------------------------------------------------

  double get totalMaxRisk {
    double total = 0;
    for (final r in recommendations) {
      total += r.maxRiskUsd ?? 0;
    }
    return total;
  }

  double get totalPotentialCredit {
    double total = 0;
    for (final r in recommendations) {
      final nc = r.netCredit ?? 0;
      final c = (r.contracts ?? 0).toDouble();
      total += nc * c * 100;
    }
    return total;
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
    _loadConfig();
    fetchRecommendations();
    fetchStatus();
    fetchMorningStatus();
  }

  // ---------------------------------------------------------------------------
  // Execute (IBKR)
  // ---------------------------------------------------------------------------

  Future<IbkrExecutionResult> executeAll({bool? dryRunOverride}) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';

    await _loadConfig();
    final cfg = config.value;
    final useDryRun = dryRunOverride ?? cfg.dryRun;

    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        dryRun: useDryRun,
        port: cfg.ibkrPort,
        clientId: cfg.ibkrClientId,
        stopLossPct: cfg.stopLossPct,
        takeProfitPct: cfg.takeProfitPct,
      );

      final execResult = _buildExecResult(
        result: result,
        dryRun: useDryRun,
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        tickers: null,
      );
      lastExecuteResult.value = execResult;
      executeMessage.value = execResult.message;
      executeState.value =
          execResult.ok ? OptionsLoadState.success : OptionsLoadState.error;
      return execResult;
    } catch (e) {
      final execResult = IbkrExecutionResult(
        ok: false,
        dryRun: useDryRun,
        stdout: '',
        stderr: e.toString(),
        message: e.toString(),
        returnCode: -1,
      );
      lastExecuteResult.value = execResult;
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return execResult;
    }
  }

  Future<IbkrExecutionResult> executeSingle(
    OptionsRecommendation rec, {
    bool? dryRunOverride,
  }) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';

    await _loadConfig();
    final cfg = config.value;
    final useDryRun = dryRunOverride ?? cfg.dryRun;

    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        tickers: [rec.ticker],
        dryRun: useDryRun,
        port: cfg.ibkrPort,
        clientId: cfg.ibkrClientId,
        stopLossPct: cfg.stopLossPct,
        takeProfitPct: cfg.takeProfitPct,
      );

      final execResult = _buildExecResult(
        result: result,
        dryRun: useDryRun,
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        tickers: [rec.ticker],
      );
      lastExecuteResult.value = execResult;
      executeMessage.value = execResult.message;
      executeState.value =
          execResult.ok ? OptionsLoadState.success : OptionsLoadState.error;
      return execResult;
    } catch (e) {
      final execResult = IbkrExecutionResult(
        ok: false,
        dryRun: useDryRun,
        stdout: '',
        stderr: e.toString(),
        message: e.toString(),
        returnCode: -1,
        tickers: [rec.ticker],
      );
      lastExecuteResult.value = execResult;
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return execResult;
    }
  }

  IbkrExecutionResult _buildExecResult({
    required Map<String, dynamic> result,
    required bool dryRun,
    String? recDate,
    List<String>? tickers,
  }) {
    final ok = result['ok'] == true;
    final details = (result['details'] as String?) ?? '';
    // Split combined details back into stdout/stderr sections
    String stdout = '';
    String stderr = '';
    if (details.contains('\nSTDERR:\n')) {
      final parts = details.split('\nSTDERR:\n');
      stdout = parts[0].replaceFirst('STDOUT:\n', '');
      stderr = parts.length > 1 ? parts[1] : '';
    } else {
      stdout = details;
    }

    final message =
        ok
            ? (dryRun
                ? 'Test Mode completed — no orders placed'
                : 'Orders submitted to IBKR')
            : ((result['message'] as String?) ?? 'Execution failed');

    return IbkrExecutionResult(
      ok: ok,
      dryRun: dryRun,
      stdout: stdout,
      stderr: stderr,
      message: message,
      returnCode: (result['returncode'] as int?) ?? -1,
      recDate: recDate,
      tickers: tickers,
    );
  }
}
