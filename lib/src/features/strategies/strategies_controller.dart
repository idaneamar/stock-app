import 'dart:developer';

import 'package:get/get.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

class StrategiesController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<StrategyItem> strategies = <StrategyItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Call after any manual strategy change (toggle, create, edit, delete).
  /// Resets the active program so manual strategy state is used.
  Future<void> clearActiveProgramOnStrategyChange() async {
    await SharedPrefsService.clearActiveProgramId();
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
        await clearActiveProgramOnStrategyChange();
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
        await clearActiveProgramOnStrategyChange();
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
        await clearActiveProgramOnStrategyChange();
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
}
