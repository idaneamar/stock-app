import 'dart:developer';

import 'package:get/get.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService _api = ApiService();

  final RxBool isLoading = false.obs;
  final RxInt totalScans = 0.obs;
  final RxInt activeStrategies = 0.obs;
  final RxInt totalStrategies = 0.obs;
  final RxInt completedToday = 0.obs;
  final RxInt inProgressScans = 0.obs;
  final RxList<ScanHistoryData> recentScans = <ScanHistoryData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchScans(), _fetchStrategies()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchScans() async {
    try {
      final response = await _api.getScans(page: 1, pageSize: 20);
      if (response.statusCode == 200) {
        final parsed = ScanHistoryResponse.fromJson(response.data);
        totalScans.value = parsed.total;
        recentScans.assignAll(parsed.data.take(5).toList());

        final today = DateTime.now();
        completedToday.value =
            parsed.data.where((s) {
              final created = DateTime.tryParse(s.createdAt) ?? DateTime(2000);
              return s.status == 'completed' &&
                  created.year == today.year &&
                  created.month == today.month &&
                  created.day == today.day;
            }).length;

        inProgressScans.value =
            parsed.data.where((s) => s.status == 'in_progress').length;
      }
    } catch (e) {
      log('Dashboard scan fetch error: $e');
    }
  }

  Future<void> _fetchStrategies() async {
    try {
      final response = await _api.getStrategies();
      if (response.statusCode == 200) {
        final parsed = StrategiesListResponse.fromJson(response.data);
        totalStrategies.value = parsed.data.items.length;
        activeStrategies.value =
            parsed.data.items.where((s) => s.enabled).length;
      }
    } catch (e) {
      log('Dashboard strategy fetch error: $e');
    }
  }
}
