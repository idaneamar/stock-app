import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/features/trades/trades_screen.dart';
import 'package:stock_app/src/features/websocket/websocket_controller.dart';
import 'package:stock_app/src/models/websocket_event.dart';
import 'package:stock_app/src/features/excel_viewer/analysis_excel_loader_screen.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';
import 'package:stock_app/src/features/stock_list/analysis_order_prepare_screen.dart';
import 'package:stock_app/src/utils/helpers/snackbar_helper.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'dart:developer';

class StockAnalysisController extends GetxController {
  final ApiService _apiService = ApiService();
  final WebSocketController _webSocketController =
      Get.find<WebSocketController>();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isDownloading = false.obs;

  final RxBool isRestartingAnalysis = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> analysisResult = <String, dynamic>{}.obs;
  final Rx<ScanHistoryData?> currentScan = Rx<ScanHistoryData?>(null);
  final RxInt analysisProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocketListeners();
  }

  void _initializeWebSocketListeners() {
    void handleAnalysisCompleted(WebSocketEvent event) {
      if (event.id != null &&
          currentScan.value != null &&
          event.id == currentScan.value!.id.toString()) {
        analysisProgress.value = 0;
        refreshCurrentScan();
      }
    }

    void handleAnalysisProgress(WebSocketEvent event) {
      if (event.id != null &&
          currentScan.value != null &&
          event.id == currentScan.value!.id.toString() &&
          event.progress != null) {
        analysisProgress.value = event.progress!;
      }
    }

    _webSocketController.addEventListener('analysis_completed', (event) {
      log('Analysis completed notification received for ID: ${event.id}');
      handleAnalysisCompleted(event);
    });

    _webSocketController.addEventListener('analysis_progress', (event) {
      log(
        'Analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      handleAnalysisProgress(event);
    });

    // Backward compatibility (legacy full/limited events)
    _webSocketController.addEventListener('full_analysis_completed', (event) {
      log('Full analysis completed notification received for ID: ${event.id}');
      handleAnalysisCompleted(event);
    });

    _webSocketController.addEventListener('limited_analysis_completed', (
      event,
    ) {
      log(
        'Limited analysis completed notification received for ID: ${event.id}',
      );
      handleAnalysisCompleted(event);
    });

    _webSocketController.addEventListener('full_analysis_progress', (event) {
      log(
        'Full analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      handleAnalysisProgress(event);
    });

    _webSocketController.addEventListener('limited_analysis_progress', (event) {
      log(
        'Limited analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      handleAnalysisProgress(event);
    });
  }

  Future<void> initializeWithScanId(int scanId) async {
    try {
      isRefreshing.value = true;
      await refreshScanData(scanId);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<ScanHistoryData?> fetchScanById(int scanId) async {
    try {
      final response = await _apiService.getScanById(scanId);

      // The API response has the scan data nested under 'data' key
      if (response.data['success'] == true && response.data['data'] != null) {
        final scanData = ScanHistoryData.fromJson(response.data['data']);
        return scanData;
      } else {
        log("API response indicates failure or no data");
        return null;
      }
    } catch (e) {
      log("Error fetching scan by ID: $e");
      return null;
    }
  }

  Future<void> refreshScanData(int scanId) async {
    try {
      isRefreshing.value = true;

      // Use the specific scan API endpoint instead of fetching all scans
      final updatedScan = await fetchScanById(scanId);
      if (updatedScan != null) {
        currentScan.value = updatedScan;
        log(
          "Scan data refreshed for ID: $scanId, Status: ${updatedScan.analysisStatus}",
        );
      } else {
        log("Failed to fetch scan data for ID: $scanId");
      }
    } catch (e) {
      log("Error refreshing scan data: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> refreshCurrentScan() async {
    if (currentScan.value != null) {
      await refreshScanData(currentScan.value!.id);
    }
  }

  Future<void> openAnalysisExcel() async {
    if (currentScan.value == null) return;

    try {
      isDownloading.value = true;

      Get.to(
        () => AnalysisExcelLoaderScreen(
          scanId: currentScan.value!.id,
          title: 'Analysis - Scan #${currentScan.value!.id}',
        ),
      );
    } catch (e) {
      log('Error opening analysis Excel: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> scanTrades() async {
    if (currentScan.value == null) return;

    try {
      isLoading.value = true;

      // Call API to get trade data
      final response = await _apiService.getScanTrades(currentScan.value!.id);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tradeResponse = TradeResponse.fromJson(response.data);

        // Navigate to trades screen
        Get.to(
          () => TradesScreen(
            tradeData: tradeResponse.data,
            analysisType: 'analysis',
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load trades');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows a program-selection dialog, then restarts analysis with the chosen program.
  Future<void> restartAnalysis({BuildContext? context}) async {
    if (currentScan.value == null) return;

    // Resolve context – use navigator overlay if none provided
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    final selectedProgramId = await _showSelectProgramDialog(ctx);
    // null = user cancelled
    if (selectedProgramId == null) return;

    try {
      isRestartingAnalysis.value = true;
      final programId = selectedProgramId.isEmpty ? null : selectedProgramId;
      final response = await _apiService.restartAnalysis(
        currentScan.value!.id,
        programId: programId,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        SnackbarHelper.showSuccess(message: 'Analysis restarted successfully');

        Get.find<HomeController>().refreshScanHistory();

        MainContainerController mainController;
        try {
          mainController = Get.find<MainContainerController>();
        } catch (e) {
          mainController = Get.put(MainContainerController(), permanent: true);
        }
        mainController.setInitialIndex(0);
        Get.offAll(() => const MainContainerScreen());
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to restart analysis',
        );
      }
    } catch (e) {
      log('Error restarting analysis: $e');
      SnackbarHelper.showError(
        message: 'Failed to restart analysis: ${e.toString()}',
      );
    } finally {
      isRestartingAnalysis.value = false;
    }
  }

  /// Shows a dialog to select a strategy set for re-analysis.
  /// Returns the selected program_id (empty string = "No Program"), or null if cancelled.
  Future<String?> _showSelectProgramDialog(BuildContext context) async {
    // Load programs list
    List<Map<String, dynamic>> programs = [];
    try {
      final response = await _apiService.getPrograms();
      if (response.statusCode == 200) {
        final data = (response.data ?? {})['data'] ?? {};
        final items = (data['items'] as List?) ?? [];
        programs =
            items
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
      }
    } catch (_) {}

    if (!context.mounted) return null;

    String selectedId = '';

    return showDialog<String>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: const Text(AppStrings.selectStrategySet),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.selectProgramForRestart,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedId,
                        decoration: const InputDecoration(
                          labelText: AppStrings.program,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text(AppStrings.noProgram),
                          ),
                          ...programs.map(
                            (p) => DropdownMenuItem<String>(
                              value: (p['program_id'] ?? '').toString(),
                              child: Text(
                                (p['name'] ?? p['program_id'] ?? '').toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => selectedId = v ?? ''),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(null),
                      child: const Text(AppStrings.cancel),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.of(dialogContext).pop(selectedId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text(AppStrings.reAnalyze),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> placeOrders() async {
    if (currentScan.value == null) return;
    Get.to(() => AnalysisOrderPrepareScreen(scanId: currentScan.value!.id));
  }
}
