// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/features/stock_list/stock_analysis_controller.dart';
import 'package:stock_app/src/features/websocket/websocket_controller.dart';
import 'package:stock_app/src/models/websocket_event.dart';
import 'package:stock_app/src/features/stock_list/all_stocks_screen.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';

class ScanAnalysisScreen extends StatelessWidget {
  final int scanId;

  const ScanAnalysisScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StockAnalysisController());
    final webSocketController = Get.find<WebSocketController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithScanId(scanId);
      _setupWebSocketListeners(controller, webSocketController);
    });

    return Obx(() {
      if (controller.currentScan.value == null &&
          controller.isRefreshing.value) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Scan #$scanId',
              style: const TextStyle(color: AppColors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColors.black,
            iconTheme: const IconThemeData(color: AppColors.white),
          ),
          drawer: const AppDrawer(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final currentScanData = controller.currentScan.value;
      if (currentScanData == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Scan #$scanId',
              style: const TextStyle(color: AppColors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColors.black,
            iconTheme: const IconThemeData(color: AppColors.white),
          ),
          drawer: const AppDrawer(),
          body: const Center(child: Text('Failed to load scan data')),
        );
      }

      final stockSymbols = currentScanData.stockSymbols;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Scan #${currentScanData.id}',
            style: const TextStyle(color: AppColors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.black,
          iconTheme: const IconThemeData(color: AppColors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () => _navigateToAllStocks(stockSymbols),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'All Stocks',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () => controller.refreshScanData(scanId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              padding: const EdgeInsets.all(16),
              color: AppColors.grey50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scan Completed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                      const Spacer(),
                      Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isRestartingAnalysis.value
                                  ? null
                                  : () => controller.restartAnalysis(
                                    context: context,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              controller.isRestartingAnalysis.value
                                  ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Restarting...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Text(
                                    'Restart Analysis',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Stocks Found: ${currentScanData.totalFound}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Scan Date: ${_formatDate(currentScanData.createdAt)}',
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                  ),
                  const SizedBox(height: 24),

                  _buildAnalysisSection(
                    title: 'Analysis',
                    status: currentScanData.analysisStatus,
                    controller: controller,
                    scanId: currentScanData.id,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnalysisSection({
    required String title,
    required String? status,
    required StockAnalysisController controller,
    required int scanId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),

          if (status == null || status.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: AppColors.blue, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    '$title will start automatically',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blue700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please wait for the analysis to begin',
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          ] else if (status.toLowerCase() == 'analyzing') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Obx(() {
                    final progress = controller.analysisProgress.value;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics,
                              color: AppColors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Analyzing: $progress%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress > 0 ? progress / 100 : null,
                          backgroundColor: AppColors.grey300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.blue,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing stocks',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please wait while we analyze the data...',
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          ] else if (status.toLowerCase() == 'completed') ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final isCurrentlyDownloading =
                            controller.isDownloading.value;

                        return ElevatedButton(
                          onPressed:
                              isCurrentlyDownloading
                                  ? null
                                  : controller.openAnalysisExcel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.grey,
                          ),
                          child:
                              isCurrentlyDownloading
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Opening...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Text(
                                    'Open Excel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final isCurrentlyLoadingTrades =
                            controller.isLoading.value;

                        return ElevatedButton(
                          onPressed:
                              isCurrentlyLoadingTrades
                                  ? null
                                  : controller.scanTrades,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.grey,
                          ),
                          child:
                              isCurrentlyLoadingTrades
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Text(
                                    'Recommendations',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.placeOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: AppColors.grey600,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for $title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $status',
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _navigateToAllStocks(List<StockSymbol> stockSymbols) {
    Get.to(
      () => AllStocksScreen(
        stockSymbols: stockSymbols,
        scanId: scanId.toString(),
      ),
    );
  }

  void _setupWebSocketListeners(
    StockAnalysisController controller,
    WebSocketController webSocketController,
  ) {
    webSocketController.addEventListener('scan_completed', (
      WebSocketEvent event,
    ) {
      if (event.id != null && event.id == scanId.toString()) {
        controller.refreshScanData(scanId);
      }
    });
  }
}
