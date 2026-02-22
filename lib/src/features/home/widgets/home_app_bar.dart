import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/home/widgets/connection_indicator.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final VoidCallback onOpenDrawer;
  final VoidCallback onDeleteAll;

  const HomeAppBar({
    super.key,
    required this.controller,
    required this.onOpenDrawer,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.stocksHome,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: UIConstants.fontXL,
            ),
          ),
          const SizedBox(width: UIConstants.spacingS),
          Obx(
            () => ConnectionIndicator(
              isConnected: controller.webSocketController.isConnected,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppColors.black,
      iconTheme: const IconThemeData(color: AppColors.white),
      actions: [
        Obx(
          () =>
              controller.isDeletingAll.value
                  ? const Padding(
                    padding: AppPadding.allL,
                    child: LoadingIndicator(color: AppColors.white),
                  )
                  : TextButton(
                    onPressed: onDeleteAll,
                    child: const Text(
                      AppStrings.deleteAllScans,
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.white),
        onPressed: onOpenDrawer,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
