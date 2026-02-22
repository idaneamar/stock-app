// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';
import 'package:stock_app/src/features/programs/programs_screen.dart';
import 'package:stock_app/src/features/strategies/strategies_screen.dart';
import 'package:stock_app/src/features/trades/closed_trades_screen.dart';
import 'package:stock_app/src/features/trades/open_trades_screen.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/widget/drawer/drawer_item_card.dart';
import 'package:stock_app/src/utils/widget/drawer/reset_all_action.dart';

class AppDrawerContent extends StatelessWidget {
  final Function(int)? onMenuSelected;

  const AppDrawerContent({super.key, this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grey, AppColors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.menu,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 30),
                DrawerItemCard(
                  icon: Icons.home,
                  iconColor: AppColors.blue,
                  title: AppStrings.home,
                  subtitle: AppStrings.drawerHomeSubtitle,
                  onTap: () => _handleMenuSelection(context, 'home'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.table_chart,
                  iconColor: AppColors.blue,
                  title: AppStrings.allExcelFiles,
                  subtitle: AppStrings.drawerExcelSubtitle,
                  onTap: () => _handleMenuSelection(context, 'show_all_excel'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.analytics,
                  iconColor: AppColors.blue,
                  title: AppStrings.allRecommendations,
                  subtitle: AppStrings.drawerRecommendationsSubtitle,
                  onTap:
                      () => _handleMenuSelection(context, 'full_active_trades'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.layers,
                  iconColor: AppColors.blue,
                  title: AppStrings.programs,
                  subtitle: AppStrings.drawerProgramsSubtitle,
                  onTap: () => _handleMenuSelection(context, 'programs'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.category,
                  iconColor: AppColors.blue,
                  title: AppStrings.strategies,
                  subtitle: AppStrings.drawerStrategiesSubtitle,
                  onTap: () => _handleMenuSelection(context, 'strategies'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.trending_up,
                  iconColor: AppColors.success,
                  title: AppStrings.openTrades,
                  subtitle: AppStrings.drawerOpenTradesSubtitle,
                  onTap: () => _handleMenuSelection(context, 'open_trades'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.trending_down,
                  iconColor: AppColors.error,
                  title: AppStrings.closedTrades,
                  subtitle: AppStrings.drawerClosedTradesSubtitle,
                  onTap: () => _handleMenuSelection(context, 'close_trades'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.delete_sweep,
                  iconColor: AppColors.warning,
                  title: AppStrings.resetAllData,
                  subtitle: AppStrings.drawerResetSubtitle,
                  onTap: () => _handleMenuSelection(context, 'reset_all'),
                ),
                const SizedBox(height: 16),
                DrawerItemCard(
                  icon: Icons.settings,
                  iconColor: AppColors.grey,
                  title: AppStrings.settings,
                  subtitle: AppStrings.drawerSettingsSubtitle,
                  onTap: () => _handleMenuSelection(context, 'settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    final navigator = Navigator.of(context);
    navigator.pop();

    if (value == 'reset_all') {
      ResetAllAction.show(navigator.context);
      return;
    }

    if (onMenuSelected != null) {
      switch (value) {
        case 'home':
          onMenuSelected!(0);
          return;
        case 'show_all_excel':
          onMenuSelected!(1);
          return;
        case 'full_active_trades':
          onMenuSelected!(2);
          return;
        case 'settings':
          onMenuSelected!(3);
          return;
      }
    }

    switch (value) {
      case 'home':
        _goToMainContainer(navigator, 0);
        break;
      case 'show_all_excel':
        _goToMainContainer(navigator, 1);
        break;
      case 'full_active_trades':
        _goToMainContainer(navigator, 2);
        break;
      case 'programs':
        Future.microtask(
          () => navigator.push(
            MaterialPageRoute(builder: (_) => const ProgramsScreen()),
          ),
        );
        break;
      case 'strategies':
        Future.microtask(
          () => navigator.push(
            MaterialPageRoute(builder: (_) => const StrategiesScreen()),
          ),
        );
        break;
      case 'open_trades':
        Future.microtask(
          () => navigator.push(
            MaterialPageRoute(builder: (_) => const OpenTradesScreen()),
          ),
        );
        break;
      case 'close_trades':
        Future.microtask(
          () => navigator.push(
            MaterialPageRoute(builder: (_) => const ClosedTradesScreen()),
          ),
        );
        break;
      case 'settings':
        _goToMainContainer(navigator, 3);
        break;
    }
  }

  void _goToMainContainer(NavigatorState navigator, int initialIndex) {
    Future.microtask(
      () => navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainContainerScreen(initialIndex: initialIndex),
        ),
        (_) => false,
      ),
    );
  }
}
