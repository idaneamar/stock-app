import 'package:flutter/material.dart';
import 'package:stock_app/src/models/active_trades_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/formatters/date_formatter.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'trade_action_badge.dart';
import 'trade_detail_row.dart';
import 'trade_strategy_badge.dart';

/// A card widget to display active trade information
class ActiveTradeCard extends StatelessWidget {
  final ActiveTrade trade;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActiveTradeCard({
    super.key,
    required this.trade,
    this.onEdit,
    this.onDelete,
  });

  bool get _isBuyAction => trade.recommendation.toLowerCase() == 'buy';
  Color get _actionColor => _isBuyAction ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: UIConstants.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      child: Padding(
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.spacingXL),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(child: _buildSymbolInfo()),
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
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: UIConstants.avatarL,
      height: UIConstants.avatarL,
      decoration: BoxDecoration(
        color: _actionColor,
        borderRadius: BorderRadius.circular(UIConstants.avatarL / 2),
      ),
      child: Center(
        child: Text(
          trade.symbol.isNotEmpty
              ? trade.symbol.substring(0, 1).toUpperCase()
              : 'T',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: UIConstants.fontXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trade.symbol,
          style: const TextStyle(
            fontSize: UIConstants.fontXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            TradeActionBadge(action: trade.recommendation),
            const SizedBox(width: UIConstants.spacingM),
            TradeStrategyBadge(strategy: trade.strategy),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        TradeDetailRow(
          label: AppStrings.entryPrice,
          value: '\$${trade.entryPrice.toStringAsFixed(2)}',
        ),
        TradeDetailRow(
          label: AppStrings.stopLoss,
          value: '\$${trade.stopLoss.toStringAsFixed(2)}',
        ),
        TradeDetailRow(
          label: AppStrings.takeProfit,
          value: '\$${trade.takeProfit.toStringAsFixed(2)}',
        ),
        TradeDetailRow(
          label: AppStrings.positionSize,
          value: trade.positionSize.toString(),
        ),
        TradeDetailRow(
          label: AppStrings.riskRewardRatio,
          value: '1:${trade.riskRewardRatio.toStringAsFixed(2)}',
        ),
        TradeDetailRow(
          label: AppStrings.entryDate,
          value: DateFormatter.formatDateISO(trade.entryDate),
        ),
        TradeDetailRow(label: AppStrings.exitDate, value: trade.exitDate),
      ],
    );
  }
}
