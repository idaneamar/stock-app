import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:stock_app/src/utils/file_helper.dart';

class ExcelViewerScreen extends StatefulWidget {
  final List<int> excelData;
  final String title;

  const ExcelViewerScreen({
    super.key,
    required this.excelData,
    required this.title,
  });

  @override
  State<ExcelViewerScreen> createState() => _ExcelViewerScreenState();
}

class _ExcelViewerScreenState extends State<ExcelViewerScreen> {
  Excel? excel;
  String? selectedSheet;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      log('Loading Excel data with ${widget.excelData.length} bytes');

      if (widget.excelData.isEmpty) {
        throw Exception('Excel data is empty');
      }

      if (widget.excelData.length < 4) {
        throw Exception(
          'Excel data is too small (${widget.excelData.length} bytes)',
        );
      }

      final firstBytes = widget.excelData.take(10).toList();
      log('First bytes: $firstBytes');

      try {
        excel = Excel.decodeBytes(widget.excelData);
        log('Excel decoded successfully');
      } catch (e) {
        log('Primary Excel decode failed: $e');

        try {
          excel = Excel.createExcel();
          log('Created empty Excel instance as fallback');

          var sheet = excel!['ErrorInfo'];

          sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
            'Error',
          );
          sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
            'Details',
          );

          sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
            'Parsing Failed',
          );
          sheet.cell(CellIndex.indexByString('B2')).value = TextCellValue(
            'The Excel file could not be parsed',
          );

          sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
            'Data Size',
          );
          sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(
            '${widget.excelData.length} bytes',
          );

          sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue(
            'First Bytes',
          );
          sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue(
            widget.excelData.take(20).join(', '),
          );

          sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
            'Suggested Action',
          );
          sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue(
            'Contact support with this information',
          );

          selectedSheet = 'ErrorInfo';
          log('Created error info sheet');
        } catch (fallbackError) {
          log('Fallback Excel creation also failed: $fallbackError');
          throw Exception(
            'Excel file is corrupted and cannot be displayed. Error: $e',
          );
        }
      }

      if (excel == null) {
        throw Exception('Failed to decode Excel file - returned null');
      }

      log('Number of sheets: ${excel!.sheets.length}');
      log('Sheet names: ${excel!.sheets.keys.toList()}');

      if (excel!.sheets.isNotEmpty) {
        selectedSheet = excel!.sheets.keys.first;
        log('Selected sheet: $selectedSheet');

        final sheet = excel!.sheets[selectedSheet];
        if (sheet != null) {
          log('Sheet has ${sheet.rows.length} rows');
        }
      } else {
        throw Exception('Excel file contains no sheets');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e, stackTrace) {
      log('Error loading Excel data: $e');
      log('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load Excel file: $e';
      });
    }
  }

  Future<void> _downloadExcelFile() async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([widget.excelData]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = '${widget.title.replaceAll(' ', '_')}.xlsx';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Excel file downloaded successfully!'),
            ),
          );
        }
      } else {
        final fileName = '${widget.title.replaceAll(' ', '_')}.xlsx';
        await FileHelper.saveFileToDownloads(widget.excelData, fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excel file saved to Downloads folder: $fileName'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      log('Error downloading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadExcelFile,
            tooltip: 'Download Excel File',
          ),
          if (excel != null && excel!.sheets.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.tab),
              onSelected: (String sheetName) {
                setState(() {
                  selectedSheet = sheetName;
                });
              },
              itemBuilder: (BuildContext context) {
                return excel!.sheets.keys.map((String sheetName) {
                  return PopupMenuItem<String>(
                    value: sheetName,
                    child: Text(sheetName),
                  );
                }).toList();
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 16, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadExcelData,
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Debug Info'),
                            content: SingleChildScrollView(
                              child: Text(
                                'Data length: ${widget.excelData.length} bytes\n'
                                'First 20 bytes: ${widget.excelData.take(20).toList()}\n'
                                'Last 10 bytes: ${widget.excelData.skip(widget.excelData.length - 10).toList()}\n'
                                'Error: $errorMessage',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Debug Info'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (excel == null || selectedSheet == null) {
      return const Center(
        child: Text('No Excel data available', style: TextStyle(fontSize: 16)),
      );
    }

    final sheet = excel!.sheets[selectedSheet];
    if (sheet == null) {
      return const Center(
        child: Text('Selected sheet not found', style: TextStyle(fontSize: 16)),
      );
    }

    return Column(
      children: [
        if (excel!.sheets.length > 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.grey50,
            child: Text(
              'Sheet: $selectedSheet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
        Expanded(child: _buildExcelTable(sheet)),
      ],
    );
  }

  Widget _buildExcelTable(Sheet sheet) {
    final rows = sheet.rows;

    if (rows.isEmpty) {
      return const Center(
        child: Text('No data in this sheet', style: TextStyle(fontSize: 16)),
      );
    }

    return InteractiveViewer(
      constrained: false,
      scaleEnabled: true,
      panEnabled: true,
      minScale: 0.5,
      maxScale: 3.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 16,
              headingRowColor: WidgetStateProperty.all(AppColors.grey50),
              columns: _buildColumns(rows.first),
              rows: _buildRows(rows.skip(1).toList()),
              border: TableBorder.all(color: AppColors.grey300, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(List<Data?> headerRow) {
    try {
      log('Building columns for ${headerRow.length} headers');
      return headerRow.asMap().entries.map((entry) {
        final index = entry.key;
        final cell = entry.value;
        final cellValue = cell?.value?.toString() ?? 'Column ${index + 1}';

        return DataColumn(
          label: Expanded(
            child: Text(
              cellValue,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList();
    } catch (e) {
      log('Error building columns: $e');
      return [DataColumn(label: Text('Error loading columns: $e'))];
    }
  }

  List<DataRow> _buildRows(List<List<Data?>> dataRows) {
    try {
      log('Building ${dataRows.length} rows');
      return dataRows.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;

        return DataRow(
          color: WidgetStateProperty.all(
            rowIndex.isEven ? AppColors.white : AppColors.grey50,
          ),
          cells: _buildCells(row),
        );
      }).toList();
    } catch (e) {
      log('Error building rows: $e');
      return [];
    }
  }

  List<DataCell> _buildCells(List<Data?> row) {
    try {
      return row.map((cell) {
        String cellValue = '';
        try {
          cellValue = cell?.value?.toString() ?? '';
        } catch (e) {
          cellValue = 'Error: $e';
          log('Error converting cell value: $e');
        }

        return DataCell(
          SizedBox(
            width: 120,
            child: Text(
              cellValue,
              style: const TextStyle(fontSize: 14, color: AppColors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList();
    } catch (e) {
      log('Error building cells: $e');
      return [DataCell(Text('Error: $e'))];
    }
  }
}
