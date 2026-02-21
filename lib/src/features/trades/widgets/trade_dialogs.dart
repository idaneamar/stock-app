import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

class TradeDialogs {
  TradeDialogs._();

  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String symbol,
    bool isOpenTrade = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isOpenTrade ? AppStrings.deleteOpenTrade : AppStrings.deleteTrade,
            ),
            content: Text(
              '${isOpenTrade ? AppStrings.deleteTradeConfirm : AppStrings.deleteTradeConfirmGeneric} $symbol?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: Text(AppStrings.delete),
              ),
            ],
          ),
    );
  }

  static Future<String?> showEditExitDateDialog({
    required BuildContext context,
    required String symbol,
    required String currentExitDate,
  }) async {
    final TextEditingController exitDateController = TextEditingController(
      text: currentExitDate,
    );
    DateTime? selectedDate;

    try {
      selectedDate = DateTime.parse(currentExitDate);
    } catch (e) {
      selectedDate = DateTime.now();
    }

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${AppStrings.editTrade} - $symbol'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.currentExitDate} $currentExitDate',
                  style: TextStyle(
                    fontSize: UIConstants.fontL,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXL),
                Text(
                  AppStrings.newExitDate,
                  style: const TextStyle(
                    fontSize: UIConstants.fontXL,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                TextFormField(
                  controller: exitDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.selectExitDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.paddingM,
                      vertical: UIConstants.paddingS,
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(
                              context,
                            ).colorScheme.copyWith(primary: AppColors.blue),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      exitDateController.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (exitDateController.text.isNotEmpty) {
                    Navigator.of(context).pop(exitDateController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: Text(AppStrings.update),
              ),
            ],
          ),
    );
  }

  static void showDeleteConfirmationGetX({
    required String symbol,
    required VoidCallback onConfirm,
    bool isOpenTrade = false,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isOpenTrade ? AppStrings.deleteOpenTrade : AppStrings.deleteTrade,
        ),
        content: Text(
          '${isOpenTrade ? AppStrings.deleteTradeConfirm : AppStrings.deleteTradeConfirmGeneric} $symbol?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true && Get.overlayContext != null) {
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
              }
            },
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (Get.isDialogOpen == true && Get.overlayContext != null) {
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
              }
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
