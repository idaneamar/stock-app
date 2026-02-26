import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_app/src/models/stock_scan_response.dart';

class SharedPrefsService {
  static const String _scanIdKey = 'scan_id';
  static const String _lastScanResponseKey = 'last_scan_response';
  static const String _useVixFilterKey = 'use_vix_filter';
  static const String _activeProgramIdKey = 'active_program_id';
  static const String _optionsServerUrlKey = 'options_server_url';
  static const String defaultOptionsServerUrl = 'http://localhost:8001/';

  // Options system configuration
  static const String _optionsIbkrPortKey = 'options_ibkr_port';
  static const String _optionsIbkrClientIdKey = 'options_ibkr_client_id';
  static const String _optionsDryRunKey = 'options_dry_run';
  static const String _optionsStopLossPctKey = 'options_stop_loss_pct';
  static const String _optionsTakeProfitPctKey = 'options_take_profit_pct';
  static const String _optionsPortfolioSizeKey = 'options_portfolio_size';
  static const String _optionsPrefetchYearsKey = 'options_prefetch_years';
  static const String _optionsMaxTradesKey = 'options_max_trades';

  static Future<void> saveScanId(int scanId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scanIdKey, scanId);
  }

  static Future<int?> getScanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scanIdKey);
  }

  static Future<void> saveLastScanResponse(StockScanResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(response.toJson());
    await prefs.setString(_lastScanResponseKey, jsonString);
  }

  static Future<StockScanResponse?> getLastScanResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastScanResponseKey);

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return StockScanResponse.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearScanData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scanIdKey);
    await prefs.remove(_lastScanResponseKey);
  }

  /// Global "Use VIX filter" setting (default true = use VIX).
  static Future<void> setUseVixFilter(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useVixFilterKey, value);
  }

  static Future<bool> getUseVixFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useVixFilterKey) ?? true;
  }

  /// Active program id selected in Strategies (used by Home scan).
  static Future<void> setActiveProgramId(String programId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProgramIdKey, programId);
  }

  static Future<String> getActiveProgramId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProgramIdKey) ?? '';
  }

  /// Clears active program (e.g. after strategy changes). Persists empty so "No Program" is restored.
  static Future<void> clearActiveProgramId() async {
    await setActiveProgramId('');
  }

  /// URL of the local options server (e.g. http://localhost:8001/).
  /// Defaults to localhost:8001 which is where run_options_server.py listens.
  static Future<void> setOptionsServerUrl(String url) async {
    var normalized = url.trim();
    if (!normalized.endsWith('/')) normalized = '$normalized/';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_optionsServerUrlKey, normalized);
  }

  static Future<String> getOptionsServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_optionsServerUrlKey) ?? defaultOptionsServerUrl;
  }

  // ---------------------------------------------------------------------------
  // Options system configuration
  // ---------------------------------------------------------------------------

  /// IBKR port: 7497 (paper, default) or 7496 (live)
  static Future<void> setOptionsIbkrPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_optionsIbkrPortKey, port);
  }

  static Future<int> getOptionsIbkrPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_optionsIbkrPortKey) ?? 7497;
  }

  /// IBKR client ID (default 1)
  static Future<void> setOptionsIbkrClientId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_optionsIbkrClientIdKey, id);
  }

  static Future<int> getOptionsIbkrClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_optionsIbkrClientIdKey) ?? 1;
  }

  /// Dry-run mode (default false — real orders)
  static Future<void> setOptionsDryRun(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_optionsDryRunKey, value);
  }

  static Future<bool> getOptionsDryRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_optionsDryRunKey) ?? false;
  }

  /// Stop-loss percentage as a fraction (default 1.0 = 100% of max loss)
  static Future<void> setOptionsStopLossPct(double pct) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_optionsStopLossPctKey, pct);
  }

  static Future<double> getOptionsStopLossPct() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_optionsStopLossPctKey) ?? 1.0;
  }

  /// Take-profit percentage as a fraction (default 0.5 = 50% of max profit)
  static Future<void> setOptionsTakeProfitPct(double pct) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_optionsTakeProfitPctKey, pct);
  }

  static Future<double> getOptionsTakeProfitPct() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_optionsTakeProfitPctKey) ?? 0.5;
  }

  /// Portfolio size in USD (default 250000)
  static Future<void> setOptionsPortfolioSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_optionsPortfolioSizeKey, size);
  }

  static Future<double> getOptionsPortfolioSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_optionsPortfolioSizeKey) ?? 250000.0;
  }

  /// Prefetch years as comma-separated string (e.g. "2023,2024,2025")
  static Future<void> setOptionsPrefetchYears(List<int> years) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_optionsPrefetchYearsKey, years.join(','));
  }

  static Future<List<int>> getOptionsPrefetchYears() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_optionsPrefetchYearsKey);
    if (raw == null || raw.isEmpty) {
      return [DateTime.now().year];
    }
    return raw
        .split(',')
        .map((s) => int.tryParse(s.trim()) ?? DateTime.now().year)
        .toList();
  }

  /// Maximum number of recommendations to display (default 10)
  static Future<void> setOptionsMaxTrades(int n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_optionsMaxTradesKey, n);
  }

  static Future<int> getOptionsMaxTrades() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_optionsMaxTradesKey) ?? 10;
  }
}
