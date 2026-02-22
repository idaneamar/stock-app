// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/excel/all_excel_controller.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/settings/settings_controller.dart';
import 'package:stock_app/src/features/trades/full_active_trades_controller.dart';

class MainContainerController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeScreen(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _refreshScreenData(index);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _refreshScreenData(index);
  }

  void _refreshScreenData(int index) {
    try {
      switch (index) {
        case 0: // Home Screen
          final homeController = Get.find<HomeController>();
          homeController.refreshScanHistory();
          break;
        case 1: // All Excel Screen
          final excelController = Get.find<AllExcelController>();
          excelController.refreshScans();
          break;
        case 2: // All Recommendations Screen
          final fullTradesController = Get.find<FullActiveTradesController>();
          fullTradesController.refreshFullActiveTrades();
          break;
        case 3: // Settings Screen
          final settingsController = Get.put(
            SettingsController(),
            permanent: true,
          );
          settingsController.refreshSettings();
          break;
      }
    } catch (_) {
      // Controllers might not be initialized yet, which is fine.
    }
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void setInitialIndex(int index) {
    currentIndex.value = index;
  }
}
