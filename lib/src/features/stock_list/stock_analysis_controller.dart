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

  Future<void> restartAnalysis() async {
    if (currentScan.value == null) return;

    try {
      isRestartingAnalysis.value = true;

      final response = await _apiService.restartAnalysis(currentScan.value!.id);

      if (response.statusCode == 200 && response.data['success'] == true) {
        SnackbarHelper.showSuccess(message: 'Analysis restarted successfully');

        // Navigate to MainContainerScreen and refresh home data
        Get.find<HomeController>().refreshScanHistory();

        // Ensure the MainContainerController exists and is set to home screen
        MainContainerController mainController;
        try {
          mainController = Get.find<MainContainerController>();
        } catch (e) {
          // If controller doesn't exist, it will be created by MainContainerScreen
          mainController = Get.put(MainContainerController(), permanent: true);
        }

        // Set to home screen before navigation
        mainController.setInitialIndex(0);

        // Navigate to MainContainerScreen
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

  Future<void> placeOrders() async {
    if (currentScan.value == null) return;
    Get.to(() => AnalysisOrderPrepareScreen(scanId: currentScan.value!.id));
  }
}
