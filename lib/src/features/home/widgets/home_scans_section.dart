import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/home/widgets/scan_history_card.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class HomeScansSection extends StatelessWidget {
  final HomeController controller;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final void Function(int scanId, String status) onDelete;
  final void Function(int scanId) onOpenScan;

  const HomeScansSection({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onDelete,
    required this.onOpenScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaginationInfo(controller: controller),
        Expanded(child: _ScansList(this)),
      ],
    );
  }
}

class _PaginationInfo extends StatelessWidget {
  final HomeController controller;

  const _PaginationInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey, width: UIConstants.borderWidthThin),
        ),
      ),
      child: Obx(() {
        if (controller.isInitialLoading.value) {
          return Text(
            AppStrings.loading,
            style: TextStyle(fontSize: UIConstants.fontL, color: AppColors.grey),
          );
        }
        return Text(
          controller.paginationInfo,
          style: TextStyle(fontSize: UIConstants.fontL, color: AppColors.grey),
        );
      }),
    );
  }
}

class _ScansList extends StatelessWidget {
  final HomeScansSection section;

  const _ScansList(this.section);

  @override
  Widget build(BuildContext context) {
    final controller = section.controller;
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const LoadingWidget(color: AppColors.black);
      }
      if (controller.scanHistory.isEmpty) {
        return const EmptyStateWidget(
          title: AppStrings.tapToScanStocks,
        );
      }
      return RefreshIndicator(
        onRefresh: () async => section.onRefresh(),
        color: AppColors.black,
        child: ListView.builder(
          controller: section.scrollController,
          padding: AppPadding.allL,
          itemCount:
              controller.scanHistory.length + (controller.hasMoreDataToLoad ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.scanHistory.length) {
              return _LoadMoreButton(controller: controller, onPressed: section.onLoadMore);
            }
            final scan = controller.scanHistory[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: UIConstants.marginM),
              child: _ScanCard(
                controller: controller,
                scan: scan,
                onOpen: () => section.onOpenScan(scan.id),
                onDelete: () => section.onDelete(scan.id, scan.status),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ScanCard extends StatelessWidget {
  final HomeController controller;
  final ScanHistoryData scan;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _ScanCard({
    required this.controller,
    required this.scan,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scanId = scan.id.toString();
    return Obx(
      () => ScanHistoryCard(
        scan: scan,
        scanProgress: controller.scanProgress[scanId],
        onTap: onOpen,
        onLongPress: onDelete,
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: AppPadding.allL,
          child: LoadingWidget(color: AppColors.black),
        );
      }
      return Padding(
        padding: AppPadding.allL,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
          ),
          child: const Text(AppStrings.loadMore),
        ),
      );
    });
  }
}
