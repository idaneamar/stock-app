import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';

class AppDialogs {
  /// Safely closes a dialog without triggering snackbar controller issues
  static void _closeDialog() {
    if (Get.isDialogOpen == true) {
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
    }
  }

  static void showCustom({
    required String title,
    required Widget content,
    VoidCallback? onCancel,
    VoidCallback? onOk,
  }) {
    Get.dialog(
      AlertDialog(
        content: content,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          InkWell(
            onTap: () {
              _closeDialog();
              if (onCancel != null) onCancel();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _closeDialog();
              if (onOk != null) onOk();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Okay",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showDeleteConfirmation({
    required String title,
    required String message,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          InkWell(
            onTap: () {
              _closeDialog();
              if (onCancel != null) onCancel();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              _closeDialog();
              if (onDelete != null) onDelete();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Delete",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static void showDeleteConfirmationWithLoading({
    required String title,
    required String message,
    required RxBool isDeleting,
    VoidCallback? onCancel,
    Future<bool> Function()? onDelete,
  }) {
    Get.dialog(
      Obx(
        () => PopScope(
          canPop: !isDeleting.value,
          child: AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            actions: [
              InkWell(
                onTap: isDeleting.value
                    ? null
                    : () {
                        _closeDialog();
                        if (onCancel != null) onCancel();
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDeleting.value
                        ? AppColors.grey.withValues(alpha: 0.5)
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: isDeleting.value
                          ? AppColors.white.withValues(alpha: 0.5)
                          : AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: isDeleting.value
                    ? null
                    : () async {
                        if (onDelete != null) {
                          final success = await onDelete();
                          if (success) {
                            _closeDialog();
                          }
                        }
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDeleting.value
                        ? AppColors.error.withValues(alpha: 0.7)
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: isDeleting.value
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Deleting...",
                              style: TextStyle(color: AppColors.white),
                            ),
                          ],
                        )
                      : const Text(
                          "Delete",
                          style: TextStyle(color: AppColors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
