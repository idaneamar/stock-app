// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/excel/all_excel_controller.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';
import 'package:stock_app/src/features/trades/full_active_trades_controller.dart';
import 'package:stock_app/src/utils/app_dialog.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';

class ResetAllAction {
  static void show(BuildContext context) {
    final RxBool isResetting = false.obs;

    AppDialogs.showCustom(
      title: AppStrings.resetAllData,
      content: Obx(() {
        if (isResetting.value) {
          return const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.black),
              SizedBox(height: 16),
              Text(AppStrings.loading),
            ],
          );
        }
        return const Text(AppStrings.resetAllDataConfirm);
      }),
      onOk:
          isResetting.value
              ? null
              : () async {
                isResetting.value = true;
                try {
                  final response = await ApiService().resetAll();
                  if (response.data['success'] == true) {
                    if (context.mounted) {
                      UiFeedback.showSnackBar(
                        context,
                        message:
                            response.data['message'] ??
                            AppStrings.dataResetSuccessfully,
                        type: UiMessageType.success,
                      );
                    }
                    try {
                      Get.delete<MainContainerController>(force: true);
                      Get.delete<HomeController>(force: true);
                      Get.delete<AllExcelController>(force: true);
                      Get.delete<FullActiveTradesController>(force: true);
                    } catch (_) {}
                    Get.offAll(() => const MainContainerScreen());
                  } else {
                    if (context.mounted) {
                      UiFeedback.showSnackBar(
                        context,
                        message: AppStrings.failedToResetData,
                        type: UiMessageType.error,
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    UiFeedback.showSnackBar(
                      context,
                      message: '${AppStrings.failedToResetData}: $e',
                      type: UiMessageType.error,
                    );
                  }
                } finally {
                  isResetting.value = false;
                }
              },
    );
  }
}
