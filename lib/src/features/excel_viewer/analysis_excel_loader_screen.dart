import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/excel_viewer/robust_excel_viewer.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';

class AnalysisExcelLoaderScreen extends StatefulWidget {
  final int scanId;
  final String title;
  final String? analysisType;

  const AnalysisExcelLoaderScreen({
    super.key,
    required this.scanId,
    required this.title,
    this.analysisType,
  });

  @override
  State<AnalysisExcelLoaderScreen> createState() =>
      _AnalysisExcelLoaderScreenState();
}

class _AnalysisExcelLoaderScreenState extends State<AnalysisExcelLoaderScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await _apiService.getAnalysisExcel(
        widget.scanId,
        analysisType: widget.analysisType,
      );

      if (response.statusCode == 200) {
        final bytes = _extractBytes(response.data);
        if (bytes.isEmpty) {
          setState(() {
            _isLoading = false;
            _message = 'No data found for scan ${widget.scanId}.';
          });
          return;
        }

        Get.off(() => RobustExcelViewer(excelData: bytes, title: widget.title));
        return;
      }

      if (response.statusCode == 404) {
        final serverMessage = _tryDecodeServerMessage(response.data);
        setState(() {
          _isLoading = false;
          _message =
              (serverMessage?.trim().isNotEmpty ?? false)
                  ? serverMessage
                  : 'No data found for scan ${widget.scanId}.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _message = 'Failed to load Excel (Status ${response.statusCode}).';
      });
    } catch (e) {
      log('Error opening analysis Excel: $e');
      setState(() {
        _isLoading = false;
        _message = 'Failed to load Excel file.';
      });
    }
  }

  List<int> _extractBytes(dynamic data) {
    if (data is List<int>) return data;
    if (data is Uint8List) return data;
    if (data is List) return List<int>.from(data);
    return const <int>[];
  }

  String? _tryDecodeServerMessage(dynamic data) {
    try {
      final bytes = _extractBytes(data);
      if (bytes.isEmpty) return null;

      final text = utf8.decode(bytes, allowMalformed: true);
      final parsed = jsonDecode(text);
      if (parsed is Map && parsed['message'] is String) {
        return parsed['message'] as String;
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Container(
        color: AppColors.grey50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child:
            _isLoading
                ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading Excel...'),
                  ],
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      size: 56,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message ?? 'No data found.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
      ),
    );
  }
}
