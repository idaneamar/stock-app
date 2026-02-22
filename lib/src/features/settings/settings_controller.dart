import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/settings/settings_strings.dart';
import 'package:stock_app/src/features/settings/widgets/portfolio_size_edit_dialog.dart';
import 'package:stock_app/src/models/settings_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

class SettingsController extends GetxController {
  final ApiService _apiService;

  final Rx<SettingsData?> settings = Rx<SettingsData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString error = ''.obs;
  final RxBool isInitialLoading = true.obs;

  /// Global "Use VIX filter" for all scans/analyses (persisted in SharedPrefs).
  final RxBool useVixFilter = true.obs;

  // Engine toggle reactive state (mirrors Settings DB)
  final RxBool strictRules = true.obs;
  final RxBool volumeSpikeRequired = false.obs;
  final RxBool useIntraday = false.obs;
  final adxMinCtrl = TextEditingController();
  final dailyLossLimitCtrl = TextEditingController(text: '0.02');

  SettingsController({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  @override
  void onClose() {
    adxMinCtrl.dispose();
    dailyLossLimitCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      await fetchSettings();
      useVixFilter.value = await SharedPrefsService.getUseVixFilter();
      if (!isClosed) isInitialLoading.value = false;
    });
  }

  Future<void> setUseVixFilter(bool value) async {
    useVixFilter.value = value;
    await SharedPrefsService.setUseVixFilter(value);
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    error.value = '';
    try {
      log('Fetching settings...');
      final response = await _apiService.getSettings();
      if (response.statusCode == 200) {
        final data = SettingsResponse.fromJson(response.data).data;
        settings.value = data;
        _syncEngineToggles(data);
      } else {
        error.value = SettingsStrings.failedToLoadSettings;
      }
    } catch (e) {
      log('Error fetching settings: $e');
      error.value = '${SettingsStrings.failedToLoadSettings}: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _syncEngineToggles(SettingsData data) {
    strictRules.value = data.strictRules;
    volumeSpikeRequired.value = data.volumeSpikeRequired;
    useIntraday.value = data.useIntraday;
    adxMinCtrl.text = data.adxMin != null ? data.adxMin.toString() : '';
    dailyLossLimitCtrl.text = data.dailyLossLimitPct.toString();
  }

  Future<void> refreshSettings() => fetchSettings();

  Future<void> updateSettings(
    BuildContext? context, {
    required double portfolioSize,
  }) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      log('Updating settings - Portfolio Size: $portfolioSize');
      final response = await _apiService.updateSettings(
        portfolioSize: portfolioSize,
      );
      if (context != null && !context.mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = SettingsResponse.fromJson(response.data).data;
        settings.value = data;
        _syncEngineToggles(data);
        UiFeedback.showSnackBar(
          context,
          message: SettingsStrings.settingsUpdatedSuccessfully,
          type: UiMessageType.success,
        );
      } else {
        UiFeedback.showSnackBar(
          context,
          message:
              response.data['message'] ??
              SettingsStrings.failedToUpdateSettings,
          type: UiMessageType.error,
        );
      }
    } catch (e) {
      log('Error updating settings: $e');
      if (context != null && !context.mounted) return;
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.errorPrefix} $e',
        type: UiMessageType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Save all engine toggles plus portfolio size to the backend.
  Future<void> saveEngineSettings(BuildContext? context) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final portfolioSize = settings.value?.portfolioSize ?? 350000.0;
      final adxMinRaw = adxMinCtrl.text.trim();
      final adxMin = adxMinRaw.isEmpty ? null : double.tryParse(adxMinRaw);
      final dll = double.tryParse(dailyLossLimitCtrl.text.trim()) ?? 0.02;

      final response = await _apiService.updateSettings(
        portfolioSize: portfolioSize,
        strictRules: strictRules.value,
        adxMin: adxMin,
        clearAdxMin: adxMinRaw.isEmpty,
        volumeSpikeRequired: volumeSpikeRequired.value,
        useIntraday: useIntraday.value,
        dailyLossLimitPct: dll,
      );
      if (context != null && !context.mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = SettingsResponse.fromJson(response.data).data;
        settings.value = data;
        _syncEngineToggles(data);
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.engineSettingsSaved,
          type: UiMessageType.success,
        );
      } else {
        UiFeedback.showSnackBar(
          context,
          message:
              response.data['message'] ??
              SettingsStrings.failedToUpdateSettings,
          type: UiMessageType.error,
        );
      }
    } catch (e) {
      log('Error saving engine settings: $e');
      if (context != null && !context.mounted) return;
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.errorPrefix} $e',
        type: UiMessageType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> showEditDialog(BuildContext context) async {
    final initial = settings.value?.portfolioSize ?? 350000;
    final updated = await PortfolioSizeEditDialog.show(
      context,
      initialValue: initial,
    );
    if (!context.mounted) return;
    if (updated == null) return;
    await updateSettings(context, portfolioSize: updated);
  }
}
