import 'package:get/get.dart';
import 'package:stock_app/src/models/completed_scans_response.dart';
import 'package:stock_app/src/models/date_range_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'dart:developer';

class AllExcelController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<CompletedScanData> completedScans = <CompletedScanData>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

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

        initialStartDate.value = dateRangeResponse.data.firstScanDateTime;
        initialEndDate.value = dateRangeResponse.data.lastScanDateTime;

        selectedStartDate.value = dateRangeResponse.data.firstScanDateTime;
        selectedEndDate.value = DateTime.now();
        log(
          'Set default date range: ${dateRangeResponse.data.firstScanDate} to ${dateRangeResponse.data.lastScanDate}',
        );
      }
    } catch (e) {
      log('Error fetching date range: $e');
    }
    await fetchCompletedScans();
  }

  Future<void> fetchCompletedScans() async {
    try {
      isLoading.value = true;
      error.value = '';

      DateTime startDate;
      DateTime endDate;

      if (selectedStartDate.value != null && selectedEndDate.value != null) {
        startDate = DateTime.utc(
          selectedStartDate.value!.year,
          selectedStartDate.value!.month,
          selectedStartDate.value!.day,
          0,
          0,
          0,
        );
        endDate = DateTime.utc(
          selectedEndDate.value!.year,
          selectedEndDate.value!.month,
          selectedEndDate.value!.day,
          23,
          59,
          59,
        );
      } else {
        final now = DateTime.now();
        startDate = DateTime.utc(now.year, now.month, 1, 0, 0, 0);
        endDate = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
      }

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      log(
        'Fetching completed scans for Excel from $startDateStr to $endDateStr (UTC converted)',
      );

      final response = await _apiService.getCompletedScans(
        startDate: startDateStr,
        endDate: endDateStr,
      );

      if (response.statusCode == 200) {
        final completedScansResponse = CompletedScansResponse.fromJson(
          response.data,
        );
        completedScans.value = completedScansResponse.data;
        log('Fetched ${completedScans.length} completed scans for Excel');
      } else {
        error.value =
            'Failed to fetch completed scans: ${response.statusMessage}';
      }
    } catch (e) {
      error.value = 'Error fetching completed scans: $e';
      log('Error in fetchCompletedScans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshScans() async {
    await fetchCompletedScans();
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
    fetchCompletedScans();
  }

  void clearDateFilter() {
    if (initialStartDate.value != null && initialEndDate.value != null) {
      selectedStartDate.value = initialStartDate.value;
      selectedEndDate.value = initialEndDate.value;
      log('Reset to default date range');
    } else {
      selectedStartDate.value = null;
      selectedEndDate.value = null;
    }
    fetchCompletedScans();
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
}
