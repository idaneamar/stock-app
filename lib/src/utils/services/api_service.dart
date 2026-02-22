import 'package:dio/dio.dart';
import 'package:stock_app/src/utils/services/scan_service.dart';
import 'package:stock_app/src/utils/services/trades_service.dart';
import 'package:stock_app/src/utils/services/analysis_service.dart';
import 'package:stock_app/src/utils/services/order_service.dart';
import 'package:stock_app/src/utils/services/settings_service.dart';
import 'package:stock_app/src/utils/services/strategies_service.dart';
import 'package:stock_app/src/utils/services/programs_service.dart';

/// Facade for all API services
/// Provides backward compatibility while delegating to domain-specific services
class ApiService {
  final ScanService _scanService = ScanService();
  final TradesService _tradesService = TradesService();
  final AnalysisService _analysisService = AnalysisService();
  final OrderService _orderService = OrderService();
  final SettingsService _settingsService = SettingsService();
  final StrategiesService _strategiesService = StrategiesService();
  final ProgramsService _programsService = ProgramsService();

  // Scan Methods – engine toggles (strict_rules, adx_min, etc.) now come from
  // global Settings on the backend; only universe filters + programId are sent here.
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
  }) => _scanService.scanStocks(
    maxMarketCap: maxMarketCap,
    ignoreVix: ignoreVix,
    minAvgTransactionValue: minAvgTransactionValue,
    minAvgVolume: minAvgVolume,
    minMarketCap: minMarketCap,
    minPrice: minPrice,
    minVolatility: minVolatility,
    topNStocks: topNStocks,
    programId: programId,
  );

  // Programs Methods
  Future<Response> getPrograms() => _programsService.listPrograms();
  Future<Response> createProgram(Map<String, dynamic> payload) =>
      _programsService.createProgram(payload);
  Future<Response> applyProgram(String programId) =>
      _programsService.applyProgram(programId);
  Future<Response> revertToBaselineProgram() =>
      _programsService.revertToBaseline();
  Future<Response> deleteProgram(String programId) =>
      _programsService.deleteProgram(programId);

  Future<Response> getScans({int page = 1, int pageSize = 10}) =>
      _scanService.getScans(page: page, pageSize: pageSize);

  Future<Response> getScanById(int scanId) => _scanService.getScanById(scanId);

  Future<Response> deleteScan(int scanId) => _scanService.deleteScan(scanId);

  Future<Response> deleteAllScans() => _scanService.deleteAllScans();

  Future<Response> getCompletedScans({
    required String startDate,
    required String endDate,
  }) => _scanService.getCompletedScans(startDate: startDate, endDate: endDate);

  Future<Response> getScanDateRange() => _scanService.getScanDateRange();

  Future<Response> getAllScannedStocksExcel(String scanId) =>
      _scanService.getAllScannedStocksExcel(scanId);

  Future<Response> restartAnalysis(int scanId, {String? programId}) =>
      _scanService.restartAnalysis(scanId, programId: programId);

  // Strategies Methods
  Future<Response> getStrategies({bool enabledOnly = false}) =>
      _strategiesService.getStrategies(enabledOnly: enabledOnly);

  Future<Response> createStrategy(Map<String, dynamic> payload) =>
      _strategiesService.createStrategy(payload);

  Future<Response> updateStrategy(int id, Map<String, dynamic> payload) =>
      _strategiesService.updateStrategy(id, payload);

  Future<Response> deleteStrategy(int id) =>
      _strategiesService.deleteStrategy(id);

  // Analysis Methods
  Future<Response> getAnalysisExcel(int scanId, {String? analysisType}) =>
      _analysisService.getAnalysisExcel(scanId, analysisType: analysisType);

  Future<Response> getScanTrades(int scanId, {String? analysisType}) =>
      _analysisService.getScanTrades(scanId, analysisType: analysisType);

  Future<Response> getCombinedActiveTradesExcel({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) => _analysisService.getCombinedActiveTradesExcel(
    startDate: startDate,
    endDate: endDate,
    analysisType: analysisType,
  );

  Future<Response> getCombinedAnalysisExcel({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) => _analysisService.getCombinedAnalysisExcel(
    startDate: startDate,
    endDate: endDate,
    analysisType: analysisType,
  );

  Future<Response> getActiveTrades({
    required String startDate,
    required String endDate,
    String? analysisType,
  }) => _analysisService.getActiveTrades(
    startDate: startDate,
    endDate: endDate,
    analysisType: analysisType,
  );

  Future<Response> getTradesExcel({
    required int scanId,
    String? analysisType,
  }) => _analysisService.getTradesExcel(
    scanId: scanId,
    analysisType: analysisType,
  );

  Future<Response> updateActiveTrades({
    required int scanId,
    required List<Map<String, dynamic>> updates,
    String? analysisType,
  }) => _analysisService.updateActiveTrades(
    scanId: scanId,
    updates: updates,
    analysisType: analysisType,
  );

  Future<Response> deleteActiveTrade({
    required int scanId,
    required String symbol,
    String? analysisType,
  }) => _analysisService.deleteActiveTrade(
    scanId: scanId,
    symbol: symbol,
    analysisType: analysisType,
  );

  // Order Methods
  Future<Response> placeOrder({required int scanId, String? analysisType}) =>
      _orderService.placeOrder(scanId: scanId, analysisType: analysisType);

  Future<Response> getOrderPreview({
    required int scanId,
    String? analysisType,
  }) =>
      _orderService.getOrderPreview(scanId: scanId, analysisType: analysisType);

  Future<Response> placeModifiedOrders({
    required int scanId,
    required List<Map<String, dynamic>> modifiedOrders,
    String? analysisType,
  }) => _orderService.placeModifiedOrders(
    scanId: scanId,
    modifiedOrders: modifiedOrders,
    analysisType: analysisType,
  );

  // Open Trades Methods
  Future<Response> getOpenTrades({required int page, required int pageSize}) =>
      _tradesService.getOpenTrades(page: page, pageSize: pageSize);

  Future<Response> exportOpenTrades() => _tradesService.exportOpenTrades();

  Future<Response> importOpenTrades(Map<String, dynamic> tradesData) =>
      _tradesService.importOpenTrades(tradesData);

  Future<Response> deleteOpenTrade(int tradeId) =>
      _tradesService.deleteOpenTrade(tradeId);

  Future<Response> updateOpenTrade({
    required int tradeId,
    required String exitDate,
  }) => _tradesService.updateOpenTrade(tradeId: tradeId, exitDate: exitDate);

  // Closed Trades Methods
  Future<Response> getClosedTrades({
    required int page,
    required int pageSize,
  }) => _tradesService.getClosedTrades(page: page, pageSize: pageSize);

  Future<Response> exportClosedTrades() => _tradesService.exportClosedTrades();

  Future<Response> importClosedTrades(List<dynamic> tradesData) =>
      _tradesService.importClosedTrades(tradesData);

  // Settings Methods
  Future<Response> getSettings() => _settingsService.getSettings();

  Future<Response> updateSettings({
    required double portfolioSize,
    bool? strictRules,
    double? adxMin,
    bool clearAdxMin = false,
    bool? volumeSpikeRequired,
    bool? useIntraday,
    double? dailyLossLimitPct,
  }) => _settingsService.updateSettings(
    portfolioSize: portfolioSize,
    strictRules: strictRules,
    adxMin: adxMin,
    clearAdxMin: clearAdxMin,
    volumeSpikeRequired: volumeSpikeRequired,
    useIntraday: useIntraday,
    dailyLossLimitPct: dailyLossLimitPct,
  );

  Future<Response> resetAll() => _settingsService.resetAll();
}
