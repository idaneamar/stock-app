// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

class SimpleDataViewer extends StatelessWidget {
  final List<int> rawData;
  final String title;
  final String error;

  const SimpleDataViewer({
    super.key,
    required this.rawData,
    required this.title,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.excelParsingFailed,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${AppStrings.errorPrefix} $error',
                      style: TextStyle(fontSize: 14, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.fileInformation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(AppStrings.fileSize, '${rawData.length} ${AppStrings.bytes}'),
                    _buildInfoRow(AppStrings.fileFormat, _detectFileFormat()),
                    _buildInfoRow(AppStrings.firstBytes, rawData.take(10).join(', ')),
                    if (rawData.length > 20)
                      _buildInfoRow(
                        AppStrings.lastBytes,
                        rawData.skip(rawData.length - 10).join(', '),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(AppStrings.saveFile),
                    onPressed: () => _showSaveDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info),
                    label: Text(AppStrings.rawData),
                    onPressed: () => _showRawDataDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grey600,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Card(
              color: AppColors.grey50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppColors.orange),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.suggestions,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(AppStrings.suggestionRefresh),
                    const SizedBox(height: 4),
                    Text(AppStrings.suggestionConnection),
                    const SizedBox(height: 4),
                    Text(AppStrings.suggestionSupport),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.grey600)),
          ),
        ],
      ),
    );
  }

  String _detectFileFormat() {
    if (rawData.length >= 4) {
      final firstFour = rawData.take(4).toList();
      if (firstFour[0] == 0x50 && firstFour[1] == 0x4B) {
        return AppStrings.zipBasedExcel;
      } else if (firstFour[0] == 0xD0 && firstFour[1] == 0xCF) {
        return AppStrings.ole2Excel;
      }
    }
    return AppStrings.unknown;
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.saveFileDialogTitle),
            content: Text(AppStrings.saveFileDialogContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.ok),
              ),
            ],
          ),
    );
  }

  void _showRawDataDialog(BuildContext context) {
    final hexData = rawData
        .take(200)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.rawDataDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.hexadecimal),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hexData,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.close),
              ),
            ],
          ),
    );
  }
}
