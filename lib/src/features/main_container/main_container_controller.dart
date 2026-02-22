import 'package:get/get.dart';
import 'package:stock_app/src/features/dashboard/dashboard_controller.dart';
import 'package:stock_app/src/features/excel/all_excel_controller.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/settings/settings_controller.dart';
import 'package:stock_app/src/features/trades/full_active_trades_controller.dart';

/// Screen indices used throughout the app.
class ScreenIndex {
  static const int dashboard = 0;
  static const int scans = 1;
  static const int programs = 2;
  static const int strategies = 3;
  static const int openTrades = 4;
  static const int closedTrades = 5;
  static const int excel = 6;
  static const int recommendations = 7;
  static const int settings = 8;

  static const int total = 9;
}

class MainContainerController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // Tracks which screens have been initialised (lazy-load screens on first visit)
  final Set<int> loadedIndices = {ScreenIndex.dashboard};

  void changeScreen(int index) {
    if (index < 0 || index >= ScreenIndex.total) return;
    loadedIndices.add(index);
    currentIndex.value = index;
    _refreshScreenData(index);
  }

  void _refreshScreenData(int index) {
    try {
      switch (index) {
        case ScreenIndex.dashboard:
          Get.find<DashboardController>().fetchDashboardData();
        case ScreenIndex.scans:
          Get.find<HomeController>().refreshScanHistory();
        case ScreenIndex.excel:
          Get.find<AllExcelController>().refreshScans();
        case ScreenIndex.recommendations:
          Get.find<FullActiveTradesController>().refreshFullActiveTrades();
        case ScreenIndex.settings:
          Get.find<SettingsController>().refreshSettings();
      }
    } catch (_) {
      // Controller might not be initialised yet — that is fine.
    }
  }
}
