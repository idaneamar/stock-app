import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

/// Helper class for showing consistent loading dialogs
class LoadingDialog {
  LoadingDialog._();

  /// Shows a simple loading dialog
  static void show({String? message}) {
    Get.dialog(
      Center(
        child: Container(
          padding: AppPadding.allXL,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                strokeWidth: UIConstants.progressStrokeM,
              ),
              if (message != null) ...[
                const SizedBox(height: UIConstants.spacingXL),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: UIConstants.fontXL,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Shows a loading dialog with pulsing animation
  static void showWithAnimation({
    required String message,
    Color? progressColor,
  }) {
    Get.dialog(
      Center(
        child: Container(
          padding: AppPadding.allXL,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: UIConstants.animationVerySlow,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? AppColors.blue,
                      ),
                      strokeWidth: UIConstants.progressStrokeM,
                    ),
                  );
                },
              ),
              const SizedBox(height: UIConstants.spacingXL),
              Text(
                message,
                style: const TextStyle(
                  fontSize: UIConstants.fontXL,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Shows a loading dialog for delete operations
  static void showDeleting(String itemName) {
    showWithAnimation(
      message: 'Deleting $itemName...',
      progressColor: AppColors.error,
    );
  }

  /// Shows a loading dialog for update operations
  static void showUpdating(String itemName) {
    showWithAnimation(
      message: 'Updating $itemName...',
      progressColor: AppColors.blue,
    );
  }

  /// Shows a loading dialog for export operations
  static void showExporting() {
    showWithAnimation(
      message: 'Exporting trades...',
      progressColor: AppColors.blue,
    );
  }

  /// Shows a loading dialog for import operations
  static void showImporting() {
    showWithAnimation(
      message: 'Importing trades...',
      progressColor: AppColors.blue,
    );
  }

  /// Hides the current loading dialog
  static void hide() {
    if (Get.isDialogOpen == true && Get.overlayContext != null) {
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
    }
  }

  /// Shows loading dialog using BuildContext (for StatefulWidget)
  static void showWithContext(
    BuildContext context, {
    required String message,
    Color? progressColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                padding: AppPadding.allXL,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.m,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: UIConstants.animationVerySlow,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor ?? AppColors.blue,
                            ),
                            strokeWidth: UIConstants.progressStrokeM,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingXL),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: UIConstants.fontXL,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// Hides the dialog using BuildContext
  static void hideWithContext(BuildContext context) {
    Navigator.of(context).pop();
  }
}
