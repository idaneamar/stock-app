import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/models/stock_scan_response.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';
import 'package:stock_app/src/features/websocket/websocket_controller.dart';
import 'package:stock_app/src/models/websocket_event.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  final WebSocketController _webSocketController = Get.put(
    WebSocketController(),
    permanent: true,
  );

  // Scan dialog parameters – universe filters only; engine toggles are in Settings
  final minMarketCapCtrl = TextEditingController(text: '120');
  final maxMarketCapCtrl = TextEditingController(text: '1500');
  final minAvgVolumeCtrl = TextEditingController(text: '15000');
  final minAvgTransactionValueCtrl = TextEditingController(text: '150000');
  final minVolatilityCtrl = TextEditingController(text: '0.4');
  final minPriceCtrl = TextEditingController(text: '2');
  final topNStocksCtrl = TextEditingController(text: '1000');
  final RxList<Map<String, dynamic>> programs = <Map<String, dynamic>>[].obs;
  final RxString selectedProgramId = ''.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var scanResponse = Rxn<StockScanResponse>();
  var scanHistory = <ScanHistoryData>[].obs;
  var scanProgress = <String, int>{}.obs;
  final Rx<ScanHistoryResponse?> scanHistoryData = Rx<ScanHistoryResponse?>(
    null,
  );

  var isLoadingMore = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 10;

  var isDeleting = false.obs;
  var isDeletingAll = false.obs;
  var isInitialLoading = true.obs;

  WebSocketController get webSocketController => _webSocketController;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
    _loadSavedDataAsync();
    _loadPrograms();
  }

  @override
  void onClose() {
    minMarketCapCtrl.dispose();
    maxMarketCapCtrl.dispose();
    minAvgVolumeCtrl.dispose();
    minAvgTransactionValueCtrl.dispose();
    minVolatilityCtrl.dispose();
    minPriceCtrl.dispose();
    topNStocksCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadPrograms() async {
    try {
      final response = await _apiService.getPrograms();
      final data = (response.data ?? {})['data'] ?? {};
      final items = (data['items'] as List?) ?? [];
      programs.assignAll(
        items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
      final savedId = await SharedPrefsService.getActiveProgramId();
      if (savedId.isNotEmpty) {
        selectedProgramId.value = savedId;
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

  Future<void> refreshPrograms() async {
    await _loadPrograms();
  }

  void _initializeWebSocket() {
    _webSocketController.connect();

    _webSocketController.addEventListener('scan_completed', (
      WebSocketEvent event,
    ) {
      log('Scan completed notification received for ID: ${event.id}');
      if (event.id != null) {
        scanProgress.remove(event.id);
      }
      _fetchScanHistory(isRefresh: true);
    });

    _webSocketController.addEventListener('scan_progress', (
      WebSocketEvent event,
    ) {
      log(
        'Scan progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      if (event.id != null && event.progress != null) {
        scanProgress[event.id!] = event.progress!;

        // Auto refresh when scan reaches 100%
        if (event.progress == 100) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _fetchScanHistory(isRefresh: true);
          });
        }
      }
    });

    _webSocketController.addEventListener('analysis_progress', (
      WebSocketEvent event,
    ) {
      log(
        'Analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      if (event.id != null && event.progress != null) {
        scanProgress['analysis_${event.id!}'] = event.progress!;
      }
    });

    _webSocketController.addEventListener('analysis_completed', (
      WebSocketEvent event,
    ) {
      log('Analysis completed notification received for ID: ${event.id}');
      if (event.id != null) {
        scanProgress.remove('analysis_${event.id}');
      }
      _fetchScanHistory(isRefresh: true);
    });

    _webSocketController.addEventListener('full_analysis_progress', (
      WebSocketEvent event,
    ) {
      log(
        'Full analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      if (event.id != null && event.progress != null) {
        scanProgress['full_${event.id!}'] = event.progress!;
      }
    });

    _webSocketController.addEventListener('limited_analysis_progress', (
      WebSocketEvent event,
    ) {
      log(
        'Limited analysis progress received for ID: ${event.id}, progress: ${event.progress}%',
      );
      if (event.id != null && event.progress != null) {
        scanProgress['limited_${event.id!}'] = event.progress!;
      }
    });

    _webSocketController.addEventListener('full_analysis_completed', (
      WebSocketEvent event,
    ) {
      log('Full analysis completed notification received for ID: ${event.id}');
      if (event.id != null) {
        scanProgress.remove('full_${event.id}');
      }
      _fetchScanHistory(isRefresh: true);
    });

    _webSocketController.addEventListener('limited_analysis_completed', (
      WebSocketEvent event,
    ) {
      log(
        'Limited analysis completed notification received for ID: ${event.id}',
      );
      if (event.id != null) {
        scanProgress.remove('limited_${event.id}');
      }
      _fetchScanHistory(isRefresh: true);
    });
  }

  void _loadSavedDataAsync() {
    Future.microtask(() async {
      try {
        final savedResponse = await SharedPrefsService.getLastScanResponse();

        if (savedResponse != null) {
          scanResponse.value = savedResponse;
        }

        await _fetchScanHistory(isRefresh: true);
      } finally {
        isInitialLoading.value = false;
      }
    });
  }

  /// Run scan using universe filter params, global VIX (Settings), and active program id.
  /// Engine toggles (strict rules, ADX, volume spike, intraday, daily loss limit)
  /// are read from global Settings on the backend.
  Future<void> fetchStocks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final ignoreVix = !(await SharedPrefsService.getUseVixFilter());
      final activeProgramId = await SharedPrefsService.getActiveProgramId();
      final programId =
          selectedProgramId.value.isEmpty
              ? (activeProgramId.isEmpty ? null : activeProgramId)
              : selectedProgramId.value;
      log(
        'Scan: program_id=${programId ?? "(No Program - backend uses enabled strategies)"}',
      );

      final response = await _apiService.scanStocks(
        maxMarketCap: (double.tryParse(maxMarketCapCtrl.text) ?? 0) * 1000000,
        ignoreVix: ignoreVix,
        minAvgTransactionValue:
            double.tryParse(minAvgTransactionValueCtrl.text) ?? 0,
        minAvgVolume: double.tryParse(minAvgVolumeCtrl.text) ?? 0,
        minMarketCap: (double.tryParse(minMarketCapCtrl.text) ?? 0) * 1000000,
        minPrice: double.tryParse(minPriceCtrl.text) ?? 0.0,
        minVolatility: double.tryParse(minVolatilityCtrl.text) ?? 0.0,
        topNStocks: double.tryParse(topNStocksCtrl.text) ?? 0,
        programId: programId?.isEmpty == true ? null : programId,
      );

      final stockScanResponse = StockScanResponse.fromJson(response.data);
      scanResponse.value = stockScanResponse;

      await SharedPrefsService.saveLastScanResponse(stockScanResponse);
      log('API Response: ${stockScanResponse.toJson()}');

      await _fetchScanHistory(isRefresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchScanHistory({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final response = await _apiService.getScans(
        page: currentPage.value,
        pageSize: pageSize,
      );

      final scanHistoryResponse = ScanHistoryResponse.fromJson(response.data);
      scanHistoryData.value = scanHistoryResponse;

      if (isRefresh) {
        scanHistory.value = scanHistoryResponse.data;
      } else {
        scanHistory.addAll(scanHistoryResponse.data);
      }

      hasMoreData.value = scanHistoryResponse.hasNext;

      log(
        "Scan History loaded: ${scanHistoryResponse.data.length} new records, total: ${scanHistory.length}",
      );
    } catch (e) {
      log("Error fetching scan history: $e");
    }
  }

  Future<void> refreshScanHistory() async {
    await _fetchScanHistory(isRefresh: true);
  }

  Future<void> loadMoreScanHistory() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await _fetchScanHistory();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<bool> deleteScanWithoutRefresh(int scanId) async {
    try {
      isDeleting.value = true;
      await _apiService.deleteScan(scanId);
      return true;
    } catch (e) {
      log("Error deleting scan: $e");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> deleteAllScans() async {
    try {
      isDeletingAll.value = true;
      await _apiService.deleteAllScans();
      await refreshScanHistory();
    } catch (e) {
      log("Error deleting all scans: $e");
    } finally {
      isDeletingAll.value = false;
    }
  }

  bool get hasMoreDataToLoad {
    final data = scanHistoryData.value;
    return data?.hasNext ?? false;
  }

  String get paginationInfo {
    final data = scanHistoryData.value;
    if (data == null) return '';

    final start = ((data.page - 1) * data.pageSize) + 1;
    final end = (data.page * data.pageSize).clamp(0, data.total);

    return 'Showing $start-$end of ${data.total} scans';
  }

  Future<void> loadNextPage() async {
    final data = scanHistoryData.value;
    if (data != null && data.hasNext && !isLoadingMore.value) {
      try {
        isLoadingMore.value = true;
        currentPage.value++;
        await _fetchScanHistory();
      } finally {
        isLoadingMore.value = false;
      }
    }
  }
}
