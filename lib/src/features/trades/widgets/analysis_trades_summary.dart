import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class AnalysisTradesSummary extends StatelessWidget {
  final String analyzedAt;
  final int tradesCount;
  final double totalInvestment;

  const AnalysisTradesSummary({
    super.key,
    required this.analyzedAt,
    required this.tradesCount,
    required this.totalInvestment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.totalTrades} $tradesCount',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Text(
            '${AppStrings.totalInvestment} \$${totalInvestment.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Text(
            '${AppStrings.analyzedAt}: $analyzedAt',
            style: TextStyle(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
