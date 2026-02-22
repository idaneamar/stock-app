import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/app_text_field.dart';

/// Scan parameters dialog content. No VIX toggle (global VIX is in Settings).
class ScanFiltersDialogContent extends StatelessWidget {
  final HomeController controller;

  const ScanFiltersDialogContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final items = controller.programs;
              final value = controller.selectedProgramId.value;
              final displayValue =
                  value.isNotEmpty
                      ? value
                      : (items.isNotEmpty
                          ? (items.first['program_id'] ?? '').toString()
                          : null);
              return DropdownButtonFormField<String>(
                initialValue: displayValue,
                decoration: const InputDecoration(
                  labelText: AppStrings.program,
                  border: OutlineInputBorder(),
                ),
                items:
                    items
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: (p['program_id'] ?? '').toString(),
                            child: Text(
                              (p['name'] ?? p['program_id'] ?? '').toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedProgramId.value = v;
                },
              );
            }),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.minMarketCap,
              controller: controller.minMarketCapCtrl,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.maxMarketCap,
              controller: controller.maxMarketCapCtrl,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.minAvgVolume,
              controller: controller.minAvgVolumeCtrl,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.minAvgTransactionValue,
              controller: controller.minAvgTransactionValueCtrl,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.minVolatility,
              controller: controller.minVolatilityCtrl,
              isDecimal: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.minPrice,
              controller: controller.minPriceCtrl,
              isDecimal: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.topNStocks,
              controller: controller.topNStocksCtrl,
            ),
            const SizedBox(height: UIConstants.spacingL),
            const Divider(height: UIConstants.spacingL * 2),
            Obx(
              () => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.strictRules),
                subtitle: Text(
                  AppStrings.strictRulesHint,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                value: controller.strictRules.value,
                onChanged: (value) => controller.strictRules.value = value,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Obx(
              () => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.volumeSpikeRequired),
                value: controller.volumeSpikeRequired.value,
                onChanged:
                    (value) => controller.volumeSpikeRequired.value = value,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Obx(
              () => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.allowIntradayPrices),
                value: controller.allowIntradayPrices.value,
                onChanged:
                    (value) => controller.allowIntradayPrices.value = value,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.adxMin,
              controller: controller.adxMinCtrl,
              isDecimal: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            AppTextField(
              label: AppStrings.dailyLossLimitPct,
              controller: controller.dailyLossLimitCtrl,
              isDecimal: true,
            ),
          ],
        ),
      ),
    );
  }
}
