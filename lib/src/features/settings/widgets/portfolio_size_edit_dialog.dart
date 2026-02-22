import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/formatters/number_format.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/features/settings/settings_strings.dart';

class PortfolioSizeEditDialog {
  static Future<double?> show(
    BuildContext context, {
    required double initialValue,
  }) {
    final controller = TextEditingController(
      text: formatNumberWithCommas(initialValue),
    );

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.editSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: AppStrings.portfolioSize,
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                SettingsStrings.portfolioSizeHelperText,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.grey600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = double.tryParse(
                  normalizeNumberInput(controller.text),
                );
                if (parsed == null || parsed <= 0) {
                  UiFeedback.showSnackBar(
                    context,
                    message: SettingsStrings.invalidPortfolioSize,
                    type: UiMessageType.error,
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: const Text(AppStrings.updateSettings),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }
}
