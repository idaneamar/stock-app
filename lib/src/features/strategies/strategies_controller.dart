import 'dart:developer';

import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

class StrategiesController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<StrategyItem> strategies = <StrategyItem>[].obs;
  final RxList<Map<String, dynamic>> programs = <Map<String, dynamic>>[].obs;
  final RxString selectedProgramId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRunningScan = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchPrograms() async {
    try {
      final response = await _api.getPrograms();
      final data = (response.data ?? {})['data'] ?? {};
      final items = (data['items'] as List?) ?? [];
      programs.assignAll(
        items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
      final savedActiveId = await SharedPrefsService.getActiveProgramId();
      if (savedActiveId.isNotEmpty) {
        selectedProgramId.value = savedActiveId;
      } else {
        final active = (data['active_program'] as Map?) ?? {};
        final activeId = active['active_program_id'];
        if (activeId is String && activeId.isNotEmpty) {
          selectedProgramId.value = activeId;
        } else if (programs.isNotEmpty) {
          final firstId = (programs.first['program_id'] ?? '').toString();
          if (firstId.isNotEmpty) selectedProgramId.value = firstId;
        }
      }
    } catch (e) {
      log('Failed to load programs: $e');
    }
  }

  void setActiveProgram(String programId) {
    selectedProgramId.value = programId;
    SharedPrefsService.setActiveProgramId(programId);
  }

  Future<void> fetchStrategies({bool enabledOnly = false}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _api.getStrategies(enabledOnly: enabledOnly);
      if (response.statusCode == 200) {
        final parsed = StrategiesListResponse.fromJson(response.data);
        strategies.value = parsed.data.items;
      } else {
        error.value = response.statusMessage ?? 'Failed to load strategies';
      }
    } catch (e) {
      log('Error fetching strategies: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createStrategy(Map<String, dynamic> payload) async {
    try {
      final response = await _api.createStrategy(payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final parsed = StrategyResponse.fromJson(response.data);
        strategies.add(parsed.data);
        return true;
      }
      return false;
    } catch (e) {
      log('Error creating strategy: $e');
      return false;
    }
  }

  Future<bool> updateStrategy(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.updateStrategy(id, payload);
      if (response.statusCode == 200) {
        final parsed = StrategyResponse.fromJson(response.data);
        final index = strategies.indexWhere((s) => s.id == id);
        if (index != -1) {
          strategies[index] = parsed.data;
        }
        return true;
      }
      return false;
    } catch (e) {
      log('Error updating strategy: $e');
      return false;
    }
  }

  Future<bool> deleteStrategy(int id) async {
    try {
      final response = await _api.deleteStrategy(id);
      if (response.statusCode == 200) {
        strategies.removeWhere((s) => s.id == id);
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting strategy: $e');
      return false;
    }
  }

  StrategyItem? getById(int id) {
    try {
      return strategies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Default scan params (aligned with HomeController defaults)
  static const double _defaultMinMarketCapM = 120;
  static const double _defaultMaxMarketCapM = 1500;
  static const double _defaultMinAvgVolume = 15000;
  static const double _defaultMinAvgTransactionValue = 150000;
  static const double _defaultMinVolatility = 0.4;
  static const double _defaultMinPrice = 2;
  static const double _defaultTopN = 500;
  static const bool _defaultStrictRules = true;
  static const bool _defaultVolumeSpike = true;
  static const bool _defaultAllowIntraday = false;
  static const double _defaultAdxMin = 30;
  static const double _defaultDailyLossLimit = 0.02;

  /// Run a scan with the selected program. Uses global VIX setting (Settings).
  Future<bool> runScan() async {
    final programId = selectedProgramId.value;
    if (programId.isEmpty) return false;

    final ignoreVix = !(await SharedPrefsService.getUseVixFilter());

    try {
      isRunningScan.value = true;
      error.value = '';
      await _api.scanStocks(
        maxMarketCap: _defaultMaxMarketCapM * 1000000,
        ignoreVix: ignoreVix,
        minAvgTransactionValue: _defaultMinAvgTransactionValue,
        minAvgVolume: _defaultMinAvgVolume,
        minMarketCap: _defaultMinMarketCapM * 1000000,
        minPrice: _defaultMinPrice,
        minVolatility: _defaultMinVolatility,
        topNStocks: _defaultTopN,
        programId: programId,
        strictRules: _defaultStrictRules,
        adxMin: _defaultAdxMin,
        volumeSpikeRequired: _defaultVolumeSpike,
        dailyLossLimitPct: _defaultDailyLossLimit,
        allowIntradayPrices: _defaultAllowIntraday,
      );
      try {
        Get.find<HomeController>().refreshScanHistory();
      } catch (_) {}
      return true;
    } catch (e) {
      log('Error running scan: $e');
      error.value = e.toString();
      return false;
    } finally {
      isRunningScan.value = false;
    }
  }
}
