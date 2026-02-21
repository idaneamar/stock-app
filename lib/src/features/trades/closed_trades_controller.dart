import 'package:get/get.dart';
import 'package:stock_app/src/models/closed_trades_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/file_helper.dart';
import 'dart:developer';
import 'dart:convert';

class ClosedTradesController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<ClosedTradesData?> closedTradesData = Rx<ClosedTradesData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;
  final RxList<ClosedTrade> allTrades = <ClosedTrade>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchClosedTrades();
  }

  Future<void> fetchClosedTrades({bool isRefresh = false}) async {
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
        'Fetching closed trades - page: ${currentPage.value}, pageSize: ${pageSize.value}',
      );

      final response = await _apiService.getClosedTrades(
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (response.statusCode == 200) {
        final closedTradesResponse = ClosedTradesResponse.fromJson(
          response.data,
        );
        closedTradesData.value = closedTradesResponse.data;

        if (isRefresh || currentPage.value == 1) {
          allTrades.value = closedTradesResponse.data.items;
        } else {
          allTrades.addAll(closedTradesResponse.data.items);
        }

        log(
          'Fetched ${closedTradesResponse.data.items.length} closed trades (page ${closedTradesResponse.data.page} of ${closedTradesResponse.data.totalPages})',
        );
      } else {
        error.value =
            'Failed to fetch closed trades: ${response.statusMessage}';
      }
    } catch (e) {
      error.value = 'Error fetching closed trades: $e';
      log('Error in fetchClosedTrades: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadNextPage() async {
    final data = closedTradesData.value;
    if (data != null && data.hasNext && !isLoadingMore.value) {
      currentPage.value++;
      await fetchClosedTrades();
    }
  }

  Future<void> refreshTrades() async {
    await fetchClosedTrades(isRefresh: true);
  }

  bool get hasMoreData {
    final data = closedTradesData.value;
    return data?.hasNext ?? false;
  }

  int get totalTrades {
    final data = closedTradesData.value;
    return data?.total ?? 0;
  }

  String get paginationInfo {
    final data = closedTradesData.value;
    if (data == null) return '';

    final start = ((data.page - 1) * data.pageSize) + 1;
    final end = (data.page * data.pageSize).clamp(0, data.total);

    return 'Showing $start-$end of ${data.total} trades';
  }

  // Calculate total profit/loss for all closed trades
  double get totalProfitLoss {
    return allTrades.fold(0.0, (sum, trade) => sum + trade.profitLoss);
  }

  // Get profitable trades count
  int get profitableTradesCount {
    return allTrades.where((trade) => trade.isProfitable).length;
  }

  // Get loss trades count
  int get lossTradesCount {
    return allTrades.where((trade) => !trade.isProfitable).length;
  }

  // Calculate win rate percentage
  double get winRate {
    if (allTrades.isEmpty) return 0.0;
    return (profitableTradesCount / allTrades.length) * 100;
  }

  Future<Map<String, dynamic>> importTradesFromJson(
    List<dynamic> jsonData,
  ) async {
    try {
      log('Importing closed trades from JSON');

      final response = await _apiService.importClosedTrades(jsonData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchClosedTrades(isRefresh: true);

        log('Successfully imported closed trades');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Trades imported successfully',
          'count': response.data['data']?['count'] ?? 0,
        };
      } else {
        log('Failed to import closed trades - Status: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Failed to import trades: ${response.statusMessage ?? "Unknown error"}',
        };
      }
    } catch (e) {
      log('Error importing closed trades - Error: $e');
      return {'success': false, 'message': 'Error importing trades: $e'};
    }
  }

  Future<Map<String, dynamic>> exportClosedTrades() async {
    try {
      log('Exporting closed trades');

      final response = await _apiService.exportClosedTrades();

      if (response.statusCode == 200) {
        final jsonString = json.encode(response.data);
        final bytes = utf8.encode(jsonString);

        final timestamp = DateTime.now();
        final fileName =
            'closed_trades_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.json';

        final filePath = await FileHelper.saveFileToDownloads(bytes, fileName);

        log('Successfully exported closed trades to: $filePath');
        return {
          'success': true,
          'message': 'Trades exported successfully',
          'path': filePath,
        };
      } else {
        log('Failed to export closed trades - Status: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Failed to export trades: ${response.statusMessage ?? "Unknown error"}',
        };
      }
    } catch (e) {
      log('Error exporting closed trades - Error: $e');
      return {'success': false, 'message': 'Error exporting trades: $e'};
    }
  }
}
