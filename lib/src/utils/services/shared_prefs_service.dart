import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_app/src/models/stock_scan_response.dart';

class SharedPrefsService {
  static const String _scanIdKey = 'scan_id';
  static const String _lastScanResponseKey = 'last_scan_response';
  static const String _useVixFilterKey = 'use_vix_filter';
  static const String _activeProgramIdKey = 'active_program_id';

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
}
