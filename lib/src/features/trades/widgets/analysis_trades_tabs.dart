import 'package:flutter/material.dart';
import 'package:stock_app/src/features/trades/widgets/analysis_trade_card.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class AnalysisTradesTabs extends StatelessWidget {
  final List<Trade> trades;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Trade trade) onEdit;
  final Future<void> Function(Trade trade) onDelete;

  const AnalysisTradesTabs({
    super.key,
    required this.trades,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _TradesTab(
      trades: trades,
      emptyTitle: AppStrings.noResultsFound,
      onRefresh: onRefresh,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _TradesTab extends StatelessWidget {
  final List<Trade> trades;
  final String emptyTitle;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Trade trade) onEdit;
  final Future<void> Function(Trade trade) onDelete;

  const _TradesTab({
    required this.trades,
    required this.emptyTitle,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        subtitle: AppStrings.noTradesFoundForDateRange,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: AppPadding.allL,
        itemCount: trades.length,
        separatorBuilder:
            (_, __) => const SizedBox(height: UIConstants.spacingM),
        itemBuilder: (context, index) {
          final trade = trades[index];
          return AnalysisTradeCard(
            trade: trade,
            onEdit: () => onEdit(trade),
            onDelete: () => onDelete(trade),
          );
        },
      ),
    );
  }
}
