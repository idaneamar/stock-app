import 'package:get/get.dart';
import 'package:stock_app/src/models/open_trades_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/file_helper.dart';
import 'dart:developer';
import 'dart:convert';

class OpenTradesController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<OpenTradesData?> openTradesData = Rx<OpenTradesData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxList<OpenTrade> allTrades = <OpenTrade>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOpenTrades();
  }

  Future<void> fetchOpenTrades({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        allTrades.clear();
        isLoading.value = true;
      } else if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      error.value = '';

      log(
        'Fetching open trades - page: ${currentPage.value}, pageSize: ${pageSize.value}',
      );

      final response = await _apiService.getOpenTrades(
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (response.statusCode == 200) {
        final openTradesResponse = OpenTradesResponse.fromJson(response.data);
        openTradesData.value = openTradesResponse.data;

        if (isRefresh || currentPage.value == 1) {
          allTrades.value = openTradesResponse.data.items;
        } else {
          allTrades.addAll(openTradesResponse.data.items);
        }

        log(
          'Fetched ${openTradesResponse.data.items.length} open trades (page ${openTradesResponse.data.page} of ${openTradesResponse.data.totalPages})',
        );
      } else {
        error.value = 'Failed to fetch open trades: ${response.statusMessage}';
      }
    } catch (e) {
      error.value = 'Error fetching open trades: $e';
      log('Error in fetchOpenTrades: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadNextPage() async {
    final data = openTradesData.value;
    if (data != null && data.hasNext && !isLoadingMore.value) {
      currentPage.value++;
      await fetchOpenTrades();
    }
  }

  Future<void> refreshTrades() async {
    await fetchOpenTrades(isRefresh: true);
  }

  bool get hasMoreData {
    final data = openTradesData.value;
    return data?.hasNext ?? false;
  }

  int get totalTrades {
    final data = openTradesData.value;
    return data?.total ?? 0;
  }

  String get paginationInfo {
    final data = openTradesData.value;
    if (data == null) return '';

    final start = ((data.page - 1) * data.pageSize) + 1;
    final end = (data.page * data.pageSize).clamp(0, data.total);

    return 'Showing $start-$end of ${data.total} trades';
  }

  Future<bool> deleteOpenTrade(int tradeId) async {
    try {
      log('Deleting open trade with ID: $tradeId');

      final response = await _apiService.deleteOpenTrade(tradeId);

      if (response.statusCode == 200) {
        // Remove the trade from the local list
        allTrades.removeWhere((trade) => trade.id == tradeId);

        // Update the data counters
        final data = openTradesData.value;
        if (data != null) {
          openTradesData.value = OpenTradesData(
            items: allTrades,
            total: data.total - 1,
            page: data.page,
            pageSize: data.pageSize,
            totalPages: data.totalPages,
            hasNext: data.hasNext,
            hasPrevious: data.hasPrevious,
          );
        }

        log('Successfully deleted open trade with ID: $tradeId');
        return true;
      } else {
        log(
          'Failed to delete open trade with ID: $tradeId - Status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting open trade with ID: $tradeId - Error: $e');
      return false;
    }
  }

  Future<bool> updateOpenTrade({
    required int tradeId,
    required String exitDate,
  }) async {
    try {
      log('Updating open trade with ID: $tradeId, exit date: $exitDate');

      final response = await _apiService.updateOpenTrade(
        tradeId: tradeId,
        exitDate: exitDate,
      );

      if (response.statusCode == 200) {
        // Update the trade in the local list
        final tradeIndex = allTrades.indexWhere((trade) => trade.id == tradeId);
        if (tradeIndex != -1) {
          final existingTrade = allTrades[tradeIndex];
          allTrades[tradeIndex] = OpenTrade(
            id: existingTrade.id,
            symbol: existingTrade.symbol,
            action: existingTrade.action,
            quantity: existingTrade.quantity,
            entryPrice: existingTrade.entryPrice,
            entryDate: existingTrade.entryDate,
            stopLoss: existingTrade.stopLoss,
            takeProfit: existingTrade.takeProfit,
            targetDate: exitDate,
            scanId: existingTrade.scanId,
            analysisType: existingTrade.analysisType,
            strategy: existingTrade.strategy,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }

        log('Successfully updated open trade with ID: $tradeId');
        return true;
      } else {
        log(
          'Failed to update open trade with ID: $tradeId - Status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      log('Error updating open trade with ID: $tradeId - Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> importTradesFromJson(
    Map<String, dynamic> jsonData,
  ) async {
    try {
      log('Importing open trades from JSON');

      final response = await _apiService.importOpenTrades(jsonData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the trades list after successful import
        await fetchOpenTrades(isRefresh: true);

        log('Successfully imported open trades');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Trades imported successfully',
          'count': response.data['data']?['count'] ?? 0,
        };
      } else {
        log('Failed to import open trades - Status: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Failed to import trades: ${response.statusMessage ?? "Unknown error"}',
        };
      }
    } catch (e) {
      log('Error importing open trades - Error: $e');
      return {'success': false, 'message': 'Error importing trades: $e'};
    }
  }

  Future<Map<String, dynamic>> exportOpenTrades() async {
    try {
      log('Exporting open trades');

      final response = await _apiService.exportOpenTrades();

      if (response.statusCode == 200) {
        // Convert response data to JSON string
        final jsonString = json.encode(response.data);
        final bytes = utf8.encode(jsonString);

        // Generate filename with timestamp
        final timestamp = DateTime.now();
        final fileName =
            'open_trades_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.json';

        // Save file to downloads
        final filePath = await FileHelper.saveFileToDownloads(bytes, fileName);

        log('Successfully exported open trades to: $filePath');
        return {
          'success': true,
          'message': 'Trades exported successfully',
          'path': filePath,
        };
      } else {
        log('Failed to export open trades - Status: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Failed to export trades: ${response.statusMessage ?? "Unknown error"}',
        };
      }
    } catch (e) {
      log('Error exporting open trades - Error: $e');
      return {'success': false, 'message': 'Error exporting trades: $e'};
    }
  }
}
