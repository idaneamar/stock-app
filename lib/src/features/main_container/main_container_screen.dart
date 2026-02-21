// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/excel/all_excel_screen.dart';
import 'package:stock_app/src/features/home/home_screen.dart';
import 'package:stock_app/src/features/settings/settings_screen.dart';
import 'package:stock_app/src/features/trades/full_active_trades_screen.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';

class MainContainerScreen extends StatefulWidget {
  final int initialIndex;

  const MainContainerScreen({super.key, this.initialIndex = 0});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  late final MainContainerController controller;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MainContainerController(), permanent: true);

    screens = [
      HomeScreen(),
      AllExcelScreen(),
      FullActiveTradesScreen(),
      SettingsScreen(),
    ];

    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.changeScreen(widget.initialIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBackPressed();
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: AppDrawer(onMenuSelected: controller.changeScreen),
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: screens,
        ),
      ),
    );
  }

  void _handleBackPressed() {
    // If current page is home (index 0), do nothing
    if (controller.currentIndex.value == 0) {
      return;
    }
    // If on any other page, navigate back to home
    controller.changeScreen(0);
  }
}
