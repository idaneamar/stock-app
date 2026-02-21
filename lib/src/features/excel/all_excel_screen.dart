import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/excel/all_excel_controller.dart';
import 'package:stock_app/src/features/excel_viewer/analysis_excel_loader_screen.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';
import 'package:stock_app/src/models/completed_scans_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:stock_app/src/utils/file_helper.dart';

class AllExcelScreen extends StatelessWidget {
  AllExcelScreen({super.key});

  final AllExcelController controller = Get.put(AllExcelController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Excel Files',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white),
          onPressed: () {
            final mainController = Get.find<MainContainerController>();
            mainController.openDrawer();
          },
        ),
      ),
      body: Container(
        color: AppColors.grey50,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.error.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.grey600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshScans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.completedScans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_chart, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Excel Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No completed scans with Excel files found',
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshScans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshScans,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: AppColors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Date Filter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const Spacer(),
                            if (controller.selectedStartDate.value != null)
                              TextButton(
                                onPressed: controller.clearDateFilter,
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => Text(
                            controller.dateRangeText,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _showDateRangePicker,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Select Date Range'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => ElevatedButton.icon(
                                      onPressed:
                                          controller.selectedStartDate.value !=
                                                      null &&
                                                  controller
                                                          .selectedEndDate
                                                          .value !=
                                                      null
                                              ? _downloadCombinedExcel
                                              : null,
                                      icon: const Icon(
                                        Icons.download,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Download Combined Excel',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        disabledBackgroundColor: AppColors.grey,
                                        disabledForegroundColor:
                                            AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Excel Files Available: ${controller.completedScans.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.completedScans.length,
                    itemBuilder: (context, index) {
                      final scan = controller.completedScans[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExcelCard(scan),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExcelCard(CompletedScanData scan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.blue, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.table_chart, color: AppColors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    scan.formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openExcelFile(scan.id),
                      icon: const Icon(
                        Icons.analytics,
                        size: 16,
                        color: AppColors.white,
                      ),
                      label: const Text('Open Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    DateTime? startDate;
    DateTime? endDate;

    startDate = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedStartDate.value ?? DateTime.now(),
      firstDate: controller.initialStartDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );

    if (startDate != null) {
      endDate = await showDatePicker(
        context: Get.context!,
        initialDate: controller.selectedEndDate.value ?? DateTime.now(),
        firstDate: startDate,
        lastDate: DateTime.now(),
        helpText: 'Select End Date',
      );

      if (endDate != null) {
        controller.setDateRange(startDate, endDate);
      }
    }
  }

  void _openExcelFile(int scanId) async {
    Get.to(
      () => AnalysisExcelLoaderScreen(
        scanId: scanId,
        title: 'Analysis - Scan #$scanId',
      ),
    );
  }

  void _downloadCombinedExcel() async {
    if (controller.selectedStartDate.value == null ||
        controller.selectedEndDate.value == null) {
      UiFeedback.showSnackBar(
        Get.context,
        message: 'Please select a date range first',
        type: UiMessageType.error,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final ApiService apiService = ApiService();

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

      final response = await apiService.getCombinedAnalysisExcel(
        startDate: startDateStr,
        endDate: endDateStr,
      );

      _closeBlockingDialog();

      if (response.statusCode == 200) {
        List<int> bytes;
        if (response.data is List<int>) {
          bytes = response.data as List<int>;
        } else if (response.data is Uint8List) {
          bytes = response.data as Uint8List;
        } else if (response.data is List) {
          bytes = List<int>.from(response.data);
        } else {
          log('Unexpected data type: ${response.data.runtimeType}');
          throw Exception(
            'Unexpected response data type: ${response.data.runtimeType}',
          );
        }

        if (bytes.isEmpty) {
          throw Exception('Received empty Excel data');
        }

        await _saveExcelFile(
          bytes,
          'Analysis_Combined_${controller.dateRangeText.replaceAll('/', '-').replaceAll(' ', '_')}',
        );
      } else {
        throw Exception('Failed to download Excel file');
      }
    } catch (e) {
      _closeBlockingDialog();

      log('Error downloading full Excel: $e');

      UiFeedback.showSnackBar(
        Get.context,
        message: 'Failed to download Excel file: $e',
        type: UiMessageType.error,
      );
    }
  }

  Future<void> _saveExcelFile(List<int> bytes, String fileName) async {
    try {
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

        UiFeedback.showSnackBar(
          Get.context,
          message: 'Excel file downloaded successfully!',
          type: UiMessageType.success,
        );
      } else {
        final filePath = await FileHelper.saveFileToDownloads(
          bytes,
          '$fileName.xlsx',
        );

        UiFeedback.showSnackBar(
          Get.context,
          message: 'Excel file saved successfully to: $filePath',
          type: UiMessageType.success,
        );
      }
    } catch (e) {
      log('Error saving Excel file: $e');
      UiFeedback.showSnackBar(
        Get.context,
        message: 'Failed to save Excel file: $e',
        type: UiMessageType.error,
      );
    }
  }

  void _closeBlockingDialog() {
    if (Get.isDialogOpen == true && Get.overlayContext != null) {
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
    }
  }
}
