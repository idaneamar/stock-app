import 'package:flutter/material.dart';
import 'package:stock_app/src/features/trades/analysis_trades_controller.dart';
import 'package:stock_app/src/features/trades/widgets/analysis_trades_summary.dart';
import 'package:stock_app/src/features/trades/widgets/analysis_trades_tabs.dart';
import 'package:stock_app/src/features/trades/widgets/edit_analysis_trade_dialog.dart';
import 'package:stock_app/src/features/trades/widgets/trade_dialogs.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class TradesScreen extends StatefulWidget {
  final TradeData tradeData;
  final String analysisType;

  const TradesScreen({
    super.key,
    required this.tradeData,
    required this.analysisType,
  });

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  late final AnalysisTradesController controller;

  @override
  void initState() {
    super.initState();
    controller = AnalysisTradesController(tradeData: widget.tradeData);
    controller.refresh();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final data = controller.tradeData;
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text(
              '${AppStrings.scanPrefix}${data.scanId} - ${AppStrings.analysis} ${AppStrings.trades}',
              style: const TextStyle(color: AppColors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColors.black,
            iconTheme: const IconThemeData(color: AppColors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: UIConstants.paddingM),
                child:
                    controller.isDownloading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                        : TextButton.icon(
                          onPressed:
                              controller.isBusy
                                  ? null
                                  : () => controller.downloadExcel(context),
                          icon: const Icon(
                            Icons.download,
                            color: AppColors.white,
                            size: 16,
                          ),
                          label: const Text(
                            AppStrings.downloadExcel,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.radiusS,
                              ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
          body: Container(
            color: AppColors.grey50,
            child: Column(
              children: [
                AnalysisTradesSummary(
                  analyzedAt: data.analyzedAt,
                  tradesCount: data.analysis.length,
                  totalInvestment: controller.totalInvestment(data.analysis),
                ),
                Expanded(
                  child:
                      controller.errorMessage.isNotEmpty
                          ? ErrorStateWidget(
                            errorMessage: controller.errorMessage,
                            onRetry: controller.refresh,
                          )
                          : AnalysisTradesTabs(
                            trades: data.analysis,
                            onRefresh: controller.refresh,
                            onEdit: _editTrade,
                            onDelete: _confirmDeleteTrade,
                          ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.isBusy ? null : controller.refresh,
            backgroundColor: AppColors.black,
            child:
                controller.isBusy
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                    : const Icon(Icons.refresh, color: AppColors.white),
          ),
        );
      },
    );
  }

  Future<void> _editTrade(Trade trade) async {
    final ctx = context;
    final updates = await EditAnalysisTradeDialog.show(ctx, trade: trade);
    if (updates != null) {
      if (!ctx.mounted) return;
      await controller.updateTrade(ctx, updates);
    }
  }

  Future<void> _confirmDeleteTrade(Trade trade) async {
    final ctx = context;
    final confirmed = await TradeDialogs.showDeleteConfirmation(
      context: ctx,
      symbol: trade.symbol,
      isOpenTrade: false,
    );
    if (confirmed == true) {
      if (!ctx.mounted) return;
      await controller.deleteTrade(ctx, trade.symbol);
    }
  }
}
