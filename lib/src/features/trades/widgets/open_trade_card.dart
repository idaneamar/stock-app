import 'package:flutter/material.dart';
import 'package:stock_app/src/models/open_trades_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/formatters/date_formatter.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'trade_action_badge.dart';
import 'trade_info_column.dart';

class OpenTradeCard extends StatelessWidget {
  final OpenTrade trade;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OpenTradeCard({
    super.key,
    required this.trade,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.marginM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: UIConstants.elevationL,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.spacingL),
            _buildPriceRow(),
            const SizedBox(height: UIConstants.spacingL),
            _buildStopProfitRow(),
            const SizedBox(height: UIConstants.spacingL),
            _buildDateRow(),
            const SizedBox(height: UIConstants.spacingM),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              trade.symbol,
              style: const TextStyle(
                fontSize: UIConstants.fontXXL,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            TradeActionBadge(action: trade.action),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.blue,
                  size: UIConstants.iconM,
                ),
                tooltip: AppStrings.editTrade,
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.error,
                  size: UIConstants.iconM,
                ),
                tooltip: AppStrings.deleteTrade,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.entryPrice,
            value: '\$${trade.entryPrice.toStringAsFixed(2)}',
            valueColor: AppColors.blue,
          ),
        ),
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.quantity,
            value: trade.quantity.toString(),
            valueColor: AppColors.black,
          ),
        ),
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.totalValue,
            value:
                '\$${(trade.entryPrice * trade.quantity).toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStopProfitRow() {
    return Row(
      children: [
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.stopLoss,
            value: '\$${trade.stopLoss.toStringAsFixed(2)}',
            valueColor: AppColors.error,
          ),
        ),
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.takeProfit,
            value: '\$${trade.takeProfit.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        ),
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.strategy,
            value: trade.strategy,
            valueColor: AppColors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.entryDate,
            value: DateFormatter.formatDate(trade.entryDate),
            valueColor: AppColors.grey,
          ),
        ),
        Expanded(
          child: TradeInfoColumn(
            label: AppStrings.exitDate,
            value: trade.targetDate,
            valueColor: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${AppStrings.scanId} ${trade.scanId}',
          style: TextStyle(
            fontSize: UIConstants.fontM,
            color: AppColors.grey600,
          ),
        ),
        Text(
          trade.analysisType.toUpperCase(),
          style: const TextStyle(
            fontSize: UIConstants.fontM,
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }
}
