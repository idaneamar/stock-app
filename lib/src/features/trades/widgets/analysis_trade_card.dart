import 'package:flutter/material.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class AnalysisTradeCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnalysisTradeCard({
    super.key,
    required this.trade,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.recommendation.toLowerCase() == 'buy';
    final badgeColor = isBuy ? AppColors.success : AppColors.error;

    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.m,
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trade.symbol,
                  style: const TextStyle(
                    fontSize: UIConstants.fontXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(UIConstants.radiusS),
                ),
                child: Text(
                  trade.recommendation.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: UIConstants.fontM,
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.spacingS),
              IconButton(
                tooltip: AppStrings.edit,
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: AppColors.blue),
              ),
              IconButton(
                tooltip: AppStrings.delete,
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _Info(
                  label: AppStrings.entryPrice,
                  value: '\$${trade.entryPrice.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _Info(
                  label: AppStrings.positionSize,
                  value: trade.positionSize.toString(),
                ),
              ),
              Expanded(
                child: _Info(
                  label: AppStrings.riskRewardRatio,
                  value: trade.riskRewardRatio.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _Info(
                  label: AppStrings.stopLoss,
                  value: '\$${trade.stopLoss.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _Info(
                  label: AppStrings.takeProfit,
                  value: '\$${trade.takeProfit.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _Info(label: AppStrings.strategy, value: trade.strategy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.fontS,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: UIConstants.fontL,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
