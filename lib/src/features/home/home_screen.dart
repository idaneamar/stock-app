import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/home/widgets/home_app_bar.dart';
import 'package:stock_app/src/features/home/widgets/home_scans_section.dart';
import 'package:stock_app/src/features/home/widgets/scan_filters_dialog_content.dart';
import 'package:stock_app/src/features/stock_list/stock_list_screen.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/app_dialog.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        controller: controller,
        onOpenDrawer: () {},
        onDeleteAll: _showDeleteAllConfirmation,
      ),
      body: Container(
        color: AppColors.grey50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HomeScansSection(
                controller: controller,
                scrollController: _scrollController,
                onLoadMore: controller.loadNextPage,
                onRefresh: controller.refreshScanHistory,
                onDelete: _showDeleteConfirmation,
                onOpenScan:
                    (id) => Get.to(() => ScanAnalysisScreen(scanId: id)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "home_scan_fab",
        elevation: 8,
        onPressed: () => _openScanDialog(context),
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        label: const Text("Scan Stocks"),
        icon: const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _openScanDialog(BuildContext context) {
    controller.refreshPrograms();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.stockFilters),
          content: ScanFiltersDialogContent(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.fetchStocks();
              },
              child: const Text(AppStrings.runScan),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int scanId, String status) {
    AppDialogs.showDeleteConfirmationWithLoading(
      title: AppStrings.deleteScan,
      message:
          '${AppStrings.deleteScanConfirm}$scanId? ${AppStrings.actionCannotBeUndone}',
      isDeleting: controller.isDeleting,
      onDelete: () async {
        final success = await controller.deleteScanWithoutRefresh(scanId);
        if (success) {
          final index = controller.scanHistory.indexWhere(
            (scan) => scan.id == scanId,
          );
          if (index != -1) {
            controller.scanHistory.removeAt(index);
            final data = controller.scanHistoryData.value;
            if (data != null) {
              controller.scanHistoryData.value = ScanHistoryResponse(
                success: data.success,
                status: data.status,
                message: data.message,
                data: controller.scanHistory,
                total: data.total - 1,
                page: data.page,
                pageSize: data.pageSize,
                totalPages: data.totalPages,
                hasNext: data.hasNext,
                hasPrevious: data.hasPrevious,
              );
            }
          }
        } else {
          if (!mounted) return success;
          UiFeedback.showSnackBar(
            context,
            message: '${AppStrings.failedToDeleteScan}$scanId',
            type: UiMessageType.error,
          );
        }
        return success;
      },
    );
  }

  void _showDeleteAllConfirmation() {
    AppDialogs.showCustom(
      title: AppStrings.deleteAllScans,
      content: Text(AppStrings.deleteAllScansConfirm),
      onOk: () => controller.deleteAllScans(),
    );
  }
}
