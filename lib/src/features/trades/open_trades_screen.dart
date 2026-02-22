import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';
import 'package:stock_app/src/features/trades/open_trades_controller.dart';
import 'package:stock_app/src/features/trades/widgets/open_trade_card.dart';
import 'package:stock_app/src/features/trades/widgets/trade_dialogs.dart';
import 'package:stock_app/src/models/open_trades_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/helpers/loading_dialog.dart';
import 'package:stock_app/src/utils/helpers/snackbar_helper.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class OpenTradesScreen extends StatefulWidget {
  const OpenTradesScreen({super.key});

  @override
  State<OpenTradesScreen> createState() => _OpenTradesScreenState();
}

class _OpenTradesScreenState extends State<OpenTradesScreen> {
  final OpenTradesController controller = Get.put(OpenTradesController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAll(() => const MainContainerScreen());
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: const AppDrawer(),
        body: Container(
          color: AppColors.grey50,
          child: Column(
            children: [
              _buildPaginationInfo(),
              Expanded(child: _buildTradesList()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        AppStrings.openTrades,
        style: const TextStyle(color: AppColors.white),
      ),
      centerTitle: true,
      backgroundColor: AppColors.black,
      iconTheme: const IconThemeData(color: AppColors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: AppColors.white),
          onPressed: _exportOpenTrades,
          tooltip: AppStrings.exportOpenTrades,
        ),
        IconButton(
          icon: const Icon(Icons.upload_file, color: AppColors.white),
          onPressed: _importOpenTrades,
          tooltip: AppStrings.importOpenTrades,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: () => controller.refreshTrades(),
        ),
      ],
    );
  }

  Widget _buildPaginationInfo() {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 0.5)),
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.currentPage.value == 1) {
          return Text(
            AppStrings.loading,
            style: TextStyle(
              fontSize: UIConstants.fontL,
              color: AppColors.grey,
            ),
          );
        }
        return Text(
          controller.paginationInfo,
          style: TextStyle(fontSize: UIConstants.fontL, color: AppColors.grey),
        );
      }),
    );
  }

  Widget _buildTradesList() {
    return Obx(() {
      if (controller.isLoading.value && controller.currentPage.value == 1) {
        return const LoadingWidget(color: AppColors.blue);
      }
      if (controller.error.value.isNotEmpty) {
        return ErrorStateWidget(
          errorMessage: controller.error.value,
          onRetry: () => controller.fetchOpenTrades(isRefresh: true),
        );
      }
      if (controller.allTrades.isEmpty) {
        return EmptyStateWidget(
          title: AppStrings.noOpenTradesFound,
          icon: Icons.trending_up,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshTrades,
        color: AppColors.blue,
        child: ListView.builder(
          padding: AppPadding.allL,
          itemCount:
              controller.allTrades.length + (controller.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.allTrades.length) {
              return _buildLoadMoreButton();
            }
            final trade = controller.allTrades[index];
            return OpenTradeCard(
              trade: trade,
              onEdit: () => _showEditDialog(trade),
              onDelete: () => _showDeleteConfirmDialog(trade),
            );
          },
        ),
      );
    });
  }

  Widget _buildLoadMoreButton() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(padding: AppPadding.allL, child: LoadingWidget());
      }
      return Padding(
        padding: AppPadding.allL,
        child: ElevatedButton(
          onPressed: controller.loadNextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
          ),
          child: Text(AppStrings.loadMore),
        ),
      );
    });
  }

  void _showDeleteConfirmDialog(OpenTrade trade) async {
    final confirmed = await TradeDialogs.showDeleteConfirmation(
      context: context,
      symbol: trade.symbol,
      isOpenTrade: true,
    );
    if (confirmed == true) _deleteOpenTrade(trade);
  }

  void _deleteOpenTrade(OpenTrade trade) async {
    LoadingDialog.showWithContext(
      context,
      message: '${AppStrings.deleting} ${trade.symbol}...',
      progressColor: AppColors.error,
    );
    final success = await controller.deleteOpenTrade(trade.id);
    if (mounted) LoadingDialog.hideWithContext(context);
    if (mounted) {
      success
          ? SnackbarHelper.showSimpleSuccess(
            context,
            message: '${trade.symbol} ${AppStrings.deletedSuccessfully}',
          )
          : SnackbarHelper.showSimpleError(
            context,
            message: AppStrings.failedToDeleteTrade,
          );
    }
  }

  void _showEditDialog(OpenTrade trade) async {
    final newExitDate = await TradeDialogs.showEditExitDateDialog(
      context: context,
      symbol: trade.symbol,
      currentExitDate: trade.targetDate,
    );
    if (newExitDate != null) _updateOpenTrade(trade, newExitDate);
  }

  void _updateOpenTrade(OpenTrade trade, String newExitDate) async {
    LoadingDialog.showWithContext(
      context,
      message: '${AppStrings.updating} ${trade.symbol}...',
      progressColor: AppColors.blue,
    );
    final success = await controller.updateOpenTrade(
      tradeId: trade.id,
      exitDate: newExitDate,
    );
    if (mounted) LoadingDialog.hideWithContext(context);
    if (mounted) {
      success
          ? SnackbarHelper.showSimpleSuccess(
            context,
            message: '${trade.symbol} ${AppStrings.updatedSuccessfully}',
          )
          : SnackbarHelper.showSimpleError(
            context,
            message: AppStrings.failedToUpdateTrade,
          );
    }
  }

  void _exportOpenTrades() async {
    LoadingDialog.showWithContext(
      context,
      message: AppStrings.exportingTrades,
      progressColor: AppColors.blue,
    );
    final result = await controller.exportOpenTrades();
    if (mounted) LoadingDialog.hideWithContext(context);
    if (mounted) {
      result['success'] == true
          ? SnackbarHelper.showSimpleSuccess(
            context,
            message:
                '${result['message']}\n${AppStrings.savedTo} ${result['path']}',
          )
          : SnackbarHelper.showSimpleError(
            context,
            message: result['message'] ?? AppStrings.failedToExportTrades,
          );
    }
  }

  void _importOpenTrades() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      if (mounted)
        SnackbarHelper.showSimpleError(
          context,
          message: AppStrings.failedToReadFile,
        );
      return;
    }
    final jsonString = utf8.decode(file.bytes!);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    LoadingDialog.showWithContext(
      context,
      message: AppStrings.importingTrades,
      progressColor: AppColors.blue,
    );
    final result2 = await controller.importTradesFromJson(jsonData);
    if (mounted) LoadingDialog.hideWithContext(context);
    if (mounted) {
      result2['success'] == true
          ? SnackbarHelper.showSimpleSuccess(
            context,
            message:
                '${result2['message']} (${result2['count']} ${AppStrings.trades})',
          )
          : SnackbarHelper.showSimpleError(
            context,
            message: result2['message'] ?? AppStrings.failedToImportTrades,
          );
    }
  }
}
