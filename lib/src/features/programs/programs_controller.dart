import 'dart:developer';

import 'package:get/get.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

class ProgramsController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Map<String, dynamic>> programs = <Map<String, dynamic>>[].obs;
  final RxList<StrategyItem> allStrategies = <StrategyItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    error.value = '';
    try {
      await Future.wait([fetchPrograms(), fetchStrategies()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrograms() async {
    try {
      final response = await _api.getPrograms();
      if (response.statusCode == 200) {
        final data = (response.data ?? {})['data'] ?? {};
        final items = (data['items'] as List?) ?? [];
        programs.assignAll(
          items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
    } catch (e) {
      log('Failed to load programs: $e');
    }
  }

  Future<void> fetchStrategies() async {
    try {
      final response = await _api.getStrategies();
      if (response.statusCode == 200) {
        final parsed = StrategiesListResponse.fromJson(response.data);
        allStrategies.assignAll(parsed.data.items);
      }
    } catch (e) {
      log('Failed to load strategies: $e');
    }
  }

  /// Returns the strategy names included in a program config.
  List<String> strategyNamesForProgram(Map<String, dynamic> program) {
    final config = (program['config'] as Map?) ?? {};
    final names = (config['enabled_strategy_names'] as List?) ?? [];
    return names.map((e) => e.toString()).toList();
  }

  /// Saves updated strategy names for [program] (upsert).
  Future<bool> saveStrategyNames(
    Map<String, dynamic> program,
    List<String> names,
  ) async {
    try {
      final config = Map<String, dynamic>.from(
        (program['config'] as Map?) ?? {},
      );
      config['enabled_strategy_names'] = names;
      final payload = {
        'program_id': program['program_id'],
        'name': program['name'],
        'is_baseline': program['is_baseline'] ?? false,
        'config': config,
      };
      final response = await _api.createProgram(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPrograms();
        return true;
      }
    } catch (e) {
      log('Error saving strategy names: $e');
    }
    return false;
  }

  /// Renames [program] to [newName].
  Future<bool> renameProgram(
    Map<String, dynamic> program,
    String newName,
  ) async {
    try {
      final payload = {
        'program_id': program['program_id'],
        'name': newName,
        'is_baseline': program['is_baseline'] ?? false,
        'config': program['config'] ?? {},
      };
      final response = await _api.createProgram(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPrograms();
        return true;
      }
    } catch (e) {
      log('Error renaming program: $e');
    }
    return false;
  }

  /// Updates a strategy's rules/config.
  Future<bool> updateStrategy(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.updateStrategy(id, payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchStrategies();
        return true;
      }
    } catch (e) {
      log('Error updating strategy: $e');
    }
    return false;
  }

  /// Deletes [program]. Built-in (baseline) programs are protected on the backend.
  Future<bool> deleteProgram(Map<String, dynamic> program) async {
    try {
      final programId = (program['program_id'] ?? '').toString();
      final response = await _api.deleteProgram(programId);
      if (response.statusCode == 200) {
        // Clear saved active program if it was the deleted one
        final saved = await SharedPrefsService.getActiveProgramId();
        if (saved == programId) {
          await SharedPrefsService.clearActiveProgramId();
        }
        await fetchPrograms();
        return true;
      }
    } catch (e) {
      log('Error deleting program: $e');
    }
    return false;
  }
}
