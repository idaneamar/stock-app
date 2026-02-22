import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/app_text_field.dart';

/// Scan parameters dialog – stock universe filters and program selector only.
/// Engine toggles (strict rules, ADX, volume spike, intraday, daily loss limit)
/// are now global settings managed in the Settings screen.
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
            // Program / Strategy Set selector
            Obx(() {
              final items = controller.programs;
              final value = controller.selectedProgramId.value;
              final dropdownItems = <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text(AppStrings.noProgram),
                ),
                ...items.map(
                  (p) => DropdownMenuItem<String>(
                    value: (p['program_id'] ?? '').toString(),
                    child: Text(
                      (p['name'] ?? p['program_id'] ?? '').toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ];
              return DropdownButtonFormField<String>(
                initialValue: value,
                decoration: const InputDecoration(
                  labelText: AppStrings.program,
                  border: OutlineInputBorder(),
                ),
                items: dropdownItems,
                onChanged: (v) {
                  if (v != null) controller.selectedProgramId.value = v;
                },
              );
            }),
            const SizedBox(height: UIConstants.spacingM),
            // Universe filters
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
          ],
        ),
      ),
    );
  }
}
