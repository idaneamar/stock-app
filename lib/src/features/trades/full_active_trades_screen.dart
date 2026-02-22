import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:stock_app/src/features/trades/full_active_trades_controller.dart';
import 'package:stock_app/src/features/trades/widgets/active_trade_card.dart';
import 'package:stock_app/src/features/trades/widgets/date_filter_widget.dart';
import 'package:stock_app/src/features/trades/widgets/edit_active_trade_dialog.dart';
import 'package:stock_app/src/features/trades/widgets/trade_dialogs.dart';
import 'package:stock_app/src/models/active_trades_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/helpers/loading_dialog.dart';
import 'package:stock_app/src/utils/helpers/snackbar_helper.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/file_helper.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class FullActiveTradesScreen extends StatelessWidget {
  FullActiveTradesScreen({super.key});

  final FullActiveTradesController controller = Get.put(
    FullActiveTradesController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(color: AppColors.grey50, child: _buildContent()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        AppStrings.allRecommendations,
        style: const TextStyle(color: AppColors.white),
      ),
      centerTitle: true,
      backgroundColor: AppColors.black,
      iconTheme: const IconThemeData(color: AppColors.white),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoadingFullTrades.value) {
        return const LoadingWidget();
      }
      if (controller.fullTradesError.value.isNotEmpty) {
        return ErrorStateWidget(
          errorMessage: controller.fullTradesError.value,
          onRetry: controller.refreshFullActiveTrades,
        );
      }
      final tradesData = controller.fullActiveTrades.value;
      if (tradesData == null || tradesData.analysis.isEmpty) {
        return EmptyStateWidget(
          title: AppStrings.noTradesFound,
          subtitle: AppStrings.noTradesFoundForDateRange,
        );
      }
      return _buildTradesView(tradesData);
    });
  }

  Widget _buildTradesView(ActiveTradesData tradesData) {
    return Column(
      children: [
        _buildDateFilter(),
        _buildTradesSummary(tradesData),
        Expanded(
          child: _buildTradesTab(tradesData.analysis, AppStrings.noTradesFound),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Obx(
      () => DateFilterWidget(
        dateRangeText: controller.dateRangeText,
        hasDateFilter: controller.selectedStartDate.value != null,
        canDownload:
            controller.selectedStartDate.value != null &&
            controller.selectedEndDate.value != null,
        onSelectDateRange: _showDateRangePicker,
        onClear: controller.clearDateFilter,
        onDownload: _downloadActiveRecommendation,
      ),
    );
  }

  Widget _buildTradesSummary(ActiveTradesData data) {
    return Padding(
      padding: AppPadding.horizontalL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.totalTrades} ${data.analysis.length} (${data.totalScans} ${AppStrings.scans})',
            style: TextStyle(
              fontSize: UIConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Text(
            '${AppStrings.totalInvestment} \$${_totalInvestmentFor(data.analysis).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: UIConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  double _totalInvestmentFor(List<ActiveTrade> trades) {
    return trades.fold(
      0.0,
      (sum, trade) => sum + trade.entryPrice * trade.positionSize,
    );
  }

  Widget _buildTradesTab(List<ActiveTrade> trades, String emptyMessage) {
    if (trades.isEmpty) {
      return EmptyStateWidget(
        title: emptyMessage,
        subtitle: AppStrings.noTradesFoundForDateRange,
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refreshFullActiveTrades,
      child: ListView.builder(
        padding: AppPadding.allL,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: trades.length,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: UIConstants.marginM),
              child: ActiveTradeCard(
                trade: trades[index],
                onEdit: () => _showEditTradeDialog(trades[index]),
                onDelete: () => _showDeleteConfirmDialog(trades[index]),
              ),
            ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final startDate = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedStartDate.value ?? DateTime.now(),
      firstDate: controller.initialStartDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: AppStrings.selectStartDate,
    );
    if (startDate != null) {
      final endDate = await showDatePicker(
        context: Get.context!,
        initialDate: controller.selectedEndDate.value ?? DateTime.now(),
        firstDate: startDate,
        lastDate: DateTime.now(),
        helpText: AppStrings.selectEndDate,
      );
      if (endDate != null) controller.setDateRange(startDate, endDate);
    }
  }

  void _downloadActiveRecommendation() async {
    if (controller.selectedStartDate.value == null ||
        controller.selectedEndDate.value == null) {
      SnackbarHelper.showError(message: AppStrings.pleaseSelectDateRangeFirst);
      return;
    }
    LoadingDialog.show();
    try {
      final startDate = controller.selectedStartDate.value!;
      final endDate = controller.selectedEndDate.value!;
      final startDateStr =
          DateTime.utc(
            startDate.year,
            startDate.month,
            startDate.day,
          ).toIso8601String().split('T')[0];
      final endDateStr =
          DateTime.utc(
            endDate.year,
            endDate.month,
            endDate.day,
          ).toIso8601String().split('T')[0];
      final response = await ApiService().getCombinedActiveTradesExcel(
        startDate: startDateStr,
        endDate: endDateStr,
      );
      LoadingDialog.hide();
      if (response.statusCode == 200) {
        final bytes =
            response.data is List<int>
                ? response.data as List<int>
                : List<int>.from(response.data);
        await _saveExcelFile(
          bytes,
          'Active_Recommendation_${controller.dateRangeText.replaceAll('/', '-').replaceAll(' ', '_')}',
        );
      } else {
        throw Exception(AppStrings.failedToDownloadExcelFile);
      }
    } catch (e) {
      LoadingDialog.hide();
      SnackbarHelper.showError(
        message: '${AppStrings.errorDownloadingExcelFile} $e',
      );
    }
  }

  Future<void> _saveExcelFile(List<int> bytes, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = '$fileName.xlsx';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      SnackbarHelper.showSuccess(
        message: AppStrings.excelFileDownloadedSuccessfully,
      );
    } else {
      await FileHelper.saveFileToDownloads(bytes, '$fileName.xlsx');
      SnackbarHelper.showSuccess(
        message: '${AppStrings.excelFileSavedToDownloadsFolder} $fileName.xlsx',
      );
    }
  }

  void _showEditTradeDialog(ActiveTrade trade) {
    EditActiveTradeDialog.show(
      trade,
      (updates) => _updateTrade(trade, updates),
    );
  }

  void _updateTrade(ActiveTrade trade, Map<String, dynamic> updates) async {
    LoadingDialog.showWithAnimation(
      message: '${AppStrings.updating} ${trade.symbol}...',
    );
    final success = await controller.updateTrades(
      scanId: trade.scanId,
      updates: [updates],
    );
    LoadingDialog.hide();
    success
        ? SnackbarHelper.showSuccess(
          message: AppStrings.tradeUpdatedSuccessfully,
        )
        : SnackbarHelper.showError(message: AppStrings.failedToUpdateTrade);
  }

  void _showDeleteConfirmDialog(ActiveTrade trade) {
    TradeDialogs.showDeleteConfirmationGetX(
      symbol: trade.symbol,
      onConfirm: () => _deleteTrade(trade),
    );
  }

  void _deleteTrade(ActiveTrade trade) async {
    LoadingDialog.showWithAnimation(
      message: '${AppStrings.deleting} ${trade.symbol}...',
      progressColor: AppColors.error,
    );
    final success = await controller.deleteTrade(
      scanId: trade.scanId,
      symbol: trade.symbol,
    );
    LoadingDialog.hide();
    success
        ? SnackbarHelper.showSuccess(
          message: '${trade.symbol} ${AppStrings.deletedSuccessfully}',
        )
        : SnackbarHelper.showError(message: AppStrings.failedToDeleteTrade);
  }
}
