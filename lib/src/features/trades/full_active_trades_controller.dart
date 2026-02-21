import 'package:get/get.dart';
import 'package:stock_app/src/models/active_trades_response.dart';
import 'package:stock_app/src/models/date_range_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'dart:developer';

class FullActiveTradesController extends GetxController {
  final ApiService _apiService = ApiService();
  
  final Rx<ActiveTradesData?> fullActiveTrades = Rx<ActiveTradesData?>(null);
  final RxBool isLoadingFullTrades = false.obs;
  final RxString fullTradesError = ''.obs;
  
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  
  // Store initial date range for date picker limits
  final Rx<DateTime?> initialStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> initialEndDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeDateRange();
  }

  Future<void> _initializeDateRange() async {
    try {
      final response = await _apiService.getScanDateRange();
      if (response.statusCode == 200) {
        final dateRangeResponse = DateRangeResponse.fromJson(response.data);
        // Store initial dates for date picker limits
        initialStartDate.value = dateRangeResponse.data.firstScanDateTime;
        initialEndDate.value = dateRangeResponse.data.lastScanDateTime;
        // Set selected dates to initial values
        selectedStartDate.value = dateRangeResponse.data.firstScanDateTime;
        selectedEndDate.value = DateTime.now(); // Set default end date to today
        log('Set default date range: ${dateRangeResponse.data.firstScanDate} to ${dateRangeResponse.data.lastScanDate}');
      }
    } catch (e) {
      log('Error fetching date range: $e');
    }
    await fetchFullActiveTrades();
  }

  Future<void> fetchFullActiveTrades() async {
    try {
      isLoadingFullTrades.value = true;
      fullTradesError.value = '';

      final dateRange = _getDateRange();
      
      log('Fetching active trades for analysis');
      
      final response = await _apiService.getActiveTrades(
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
      );
      
      if (response.statusCode == 200) {
        final activeTradesResponse = ActiveTradesResponse.fromJson(response.data);
        fullActiveTrades.value = activeTradesResponse.data;
        log(
          'Fetched ${activeTradesResponse.data.analysis.length} analysis trades',
        );
      } else {
        fullTradesError.value =
            'Failed to fetch active trades: ${response.statusMessage}';
      }
    } catch (e) {
      fullTradesError.value = 'Error fetching active trades: $e';
      log('Error in fetchFullActiveTrades: $e');
    } finally {
      isLoadingFullTrades.value = false;
    }
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
    fetchFullActiveTrades(); // Only fetch full trades
  }

  void clearDateFilter() {
    // Reset to stored initial dates
    if (initialStartDate.value != null && initialEndDate.value != null) {
      selectedStartDate.value = initialStartDate.value;
      selectedEndDate.value = initialEndDate.value;
      log('Reset to default date range');
    } else {
      selectedStartDate.value = null;
      selectedEndDate.value = null;
    }
    fetchFullActiveTrades(); // Only fetch full trades
  }

  String get dateRangeText {
    if (selectedStartDate.value != null && selectedEndDate.value != null) {
      final start = selectedStartDate.value!;
      final end = selectedEndDate.value!;
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    }
    final now = DateTime.now();
    return '${1}/${now.month}/${now.year} - ${now.day}/${now.month}/${now.year}';
  }

  Map<String, String> _getDateRange() {
    DateTime startDate;
    DateTime endDate;
    
    // Use selected dates if available, otherwise use default (current month)
    if (selectedStartDate.value != null && selectedEndDate.value != null) {
      startDate = DateTime.utc(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        0, 0, 0,
      );
      endDate = DateTime.utc(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        23, 59, 59,
      );
    } else {
      // Default: Current month range (UTC)
      final now = DateTime.now();
      startDate = DateTime.utc(now.year, now.month, 1, 0, 0, 0);
      endDate = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
    }
    
    // Format UTC dates (already in UTC)
    return {
      'start': startDate.toIso8601String().split('T')[0],
      'end': endDate.toIso8601String().split('T')[0],
    };
  }

  Future<void> refreshFullActiveTrades() async {
    await fetchFullActiveTrades();
  }

  double get totalInvestment {
    final tradesData = fullActiveTrades.value;
    if (tradesData == null || tradesData.analysis.isEmpty) {
      return 0.0;
    }

    double total = 0.0;
    for (final trade in tradesData.analysis) {
      total += trade.entryPrice * trade.positionSize;
    }
    return total;
  }

  Future<bool> updateTrades({
    required int scanId,
    required List<Map<String, dynamic>> updates,
  }) async {
    try {
      log('Updating trades for scan ID: $scanId');

      final response = await _apiService.updateActiveTrades(
        scanId: scanId,
        updates: updates,
      );

      if (response.statusCode == 200) {
        log('Trades updated successfully');
        await fetchFullActiveTrades();
        return true;
      } else {
        log('Failed to update trades: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      log('Error updating trades: $e');
      return false;
    }
  }

  Future<bool> deleteTrade({
    required int scanId,
    required String symbol,
  }) async {
    try {
      log('Deleting trade for scan ID: $scanId, symbol: $symbol');

      final response = await _apiService.deleteActiveTrade(
        scanId: scanId,
        symbol: symbol,
      );

      if (response.statusCode == 200) {
        log('Trade deleted successfully');
        await fetchFullActiveTrades();
        return true;
      } else {
        log('Failed to delete trade: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      log('Error deleting trade: $e');
      return false;
    }
  }
}
