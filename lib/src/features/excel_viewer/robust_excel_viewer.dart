import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:stock_app/src/utils/file_helper.dart';

class RobustExcelViewer extends StatefulWidget {
  final List<int> excelData;
  final String title;

  const RobustExcelViewer({
    super.key,
    required this.excelData,
    required this.title,
  });

  @override
  State<RobustExcelViewer> createState() => _RobustExcelViewerState();
}

class _RobustExcelViewerState extends State<RobustExcelViewer> {
  List<List<dynamic>>? tableData;
  List<String> sheetNames = [];
  final Map<String, List<List<dynamic>>> _sheetDataByName =
      <String, List<List<dynamic>>>{};
  String? selectedSheet;
  bool isLoading = true;
  String? errorMessage;
  String parsingMethod = '';

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
        tableData = null;
        sheetNames = [];
        selectedSheet = null;
        parsingMethod = '';
        _sheetDataByName.clear();
      });

      log('Loading Excel data with ${widget.excelData.length} bytes');

      if (widget.excelData.isEmpty) {
        throw Exception('Excel data is empty');
      }

      bool success = false;

      if (!success) {
        success = await _trySpreadsheetDecoder();
      }

      if (!success) {
        success = await _tryExcelPackage();
      }

      if (!success) {
        _createErrorData();
        success = true;
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

  Future<bool> _trySpreadsheetDecoder() async {
    try {
      log('Trying spreadsheet_decoder package...');

      final decoder = SpreadsheetDecoder.decodeBytes(widget.excelData);
      log('SpreadsheetDecoder: Successfully decoded file');

      _sheetDataByName.clear();
      sheetNames = decoder.tables.keys.toList();
      log('SpreadsheetDecoder: Found ${sheetNames.length} sheets: $sheetNames');

      if (sheetNames.isNotEmpty) {
        for (final sheetName in sheetNames) {
          final table = decoder.tables[sheetName];
          if (table != null && table.rows.isNotEmpty) {
            _sheetDataByName[sheetName] = table.rows;
          } else {
            _sheetDataByName[sheetName] = <List<dynamic>>[];
          }
        }

        selectedSheet = sheetNames.first;
        final firstSheetData = _sheetDataByName[selectedSheet];

        if (firstSheetData != null && firstSheetData.isNotEmpty) {
          tableData = firstSheetData;
          parsingMethod = 'SpreadsheetDecoder';
          log(
            'SpreadsheetDecoder: Successfully loaded ${tableData!.length} rows',
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      log('SpreadsheetDecoder failed: $e');
      return false;
    }
  }

  Future<bool> _tryExcelPackage() async {
    try {
      log('Trying excel package...');

      final excel = excel_lib.Excel.decodeBytes(widget.excelData);
      log('Excel package: Successfully decoded file');

      _sheetDataByName.clear();
      sheetNames = excel.sheets.keys.toList();
      log('Excel package: Found ${sheetNames.length} sheets: $sheetNames');

      if (sheetNames.isNotEmpty) {
        for (final sheetName in sheetNames) {
          final sheet = excel.sheets[sheetName];
          if (sheet != null && sheet.rows.isNotEmpty) {
            _sheetDataByName[sheetName] =
                sheet.rows.map((row) {
                  return row
                      .map((cell) => cell?.value?.toString() ?? '')
                      .toList();
                }).toList();
          } else {
            _sheetDataByName[sheetName] = <List<dynamic>>[];
          }
        }

        selectedSheet = sheetNames.first;
        final firstSheetData = _sheetDataByName[selectedSheet];

        if (firstSheetData != null && firstSheetData.isNotEmpty) {
          tableData = firstSheetData;

          parsingMethod = 'Excel Package';
          log('Excel package: Successfully loaded ${tableData!.length} rows');
          return true;
        }
      }

      return false;
    } catch (e) {
      log('Excel package failed: $e');
      return false;
    }
  }

  void _createErrorData() {
    log('Creating error data with file information...');

    tableData = [
      ['Property', 'Value', 'Additional Info'],
      [
        'File Size',
        '${widget.excelData.length} bytes',
        'Should be > 0 for valid file',
      ],
      ['File Format', _detectFileFormat(), 'ZIP-based indicates .xlsx format'],
      [
        'First 10 bytes',
        widget.excelData.take(10).join(', '),
        'Should start with [80, 75] for ZIP',
      ],
      [
        'Parsing Status',
        'Both parsers failed',
        'SpreadsheetDecoder and Excel package',
      ],
      [
        'Data Available',
        widget.excelData.isNotEmpty ? 'Yes' : 'No',
        'File downloaded successfully',
      ],
      [
        'Suggested Action',
        'Check API response format',
        'Verify server returns valid Excel file',
      ],
      [
        'Contact Support',
        'Share this debug info',
        'Include scan ID and error details',
      ],
    ];

    sheetNames = ['Debug Info'];
    selectedSheet = 'Debug Info';
    parsingMethod = 'Error Debug Data';
    _sheetDataByName['Debug Info'] = tableData ?? <List<dynamic>>[];

    log('Created error debug data with ${tableData!.length} rows');
  }

  String _detectFileFormat() {
    if (widget.excelData.length >= 4) {
      final firstFour = widget.excelData.take(4).toList();
      if (firstFour[0] == 0x50 && firstFour[1] == 0x4B) {
        return 'ZIP-based Excel (.xlsx)';
      } else if (firstFour[0] == 0xD0 && firstFour[1] == 0xCF) {
        return 'OLE2 Excel (.xls)';
      }
    }
    return 'Unknown format';
  }

  Future<void> _downloadExcelFile() async {
    try {
      if (kIsWeb) {
        // Web download
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
        // Mobile download - save to Downloads folder
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
    return PopScope(
      canPop: true, // Allow back navigation
      child: Scaffold(
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
            if (sheetNames.length > 1)
              PopupMenuButton<String>(
                icon: const Icon(Icons.tab),
                onSelected: (String sheetName) {
                  setState(() {
                    selectedSheet = sheetName;
                    tableData = _sheetDataByName[sheetName];
                  });
                },
                itemBuilder: (BuildContext context) {
                  return sheetNames.map((String sheetName) {
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
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Excel data...'),
          ],
        ),
      );
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
            ElevatedButton(
              onPressed: _loadExcelData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: AppColors.grey50,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'Parsed using: $parsingMethod',
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              if (selectedSheet != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Sheet: $selectedSheet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ],
          ),
        ),

        Expanded(child: _buildDataTable()),

        _buildSummarySection(),
      ],
    );
  }

  Widget _buildDataTable() {
    if (tableData == null || tableData!.isEmpty) {
      return const Center(
        child: Text('No data available', style: TextStyle(fontSize: 16)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        return false;
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          overscroll: false,
          scrollbars: true,
        ),
        child: InteractiveViewer(
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
                  columns: _buildColumns(),
                  rows: _buildRows(),
                  border: TableBorder.all(color: AppColors.grey300, width: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    if (tableData == null || tableData!.isEmpty) return [];

    final headerRow = tableData!.first;
    return headerRow.asMap().entries.map((entry) {
      final index = entry.key;
      final cellValue = entry.value?.toString() ?? 'Column ${index + 1}';

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
  }

  List<DataRow> _buildRows() {
    if (tableData == null || tableData!.length <= 1) return [];

    final dataRows = tableData!.skip(1).toList();

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
  }

  List<DataCell> _buildCells(List<dynamic> row) {
    // Ensure we have the same number of cells as columns
    final numColumns = tableData!.first.length;
    final paddedRow = List<dynamic>.from(row);

    // Pad row with empty strings if needed
    while (paddedRow.length < numColumns) {
      paddedRow.add('');
    }

    return paddedRow.take(numColumns).map((cell) {
      final cellValue = cell?.toString() ?? '';

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
  }

  Widget _buildSummarySection() {
    if (tableData == null || tableData!.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalInvestment = 0.0;
    int totalTrades = 0;

    try {
      final headerRow = tableData!.first;
      int? entryPriceIndex;
      int? positionSizeIndex;

      for (int i = 0; i < headerRow.length; i++) {
        final header = headerRow[i]?.toString().toLowerCase() ?? '';
        if (header.contains('entry') && header.contains('price')) {
          entryPriceIndex = i;
        } else if (header.contains('position') && header.contains('size')) {
          positionSizeIndex = i;
        }
      }

      if (entryPriceIndex != null && positionSizeIndex != null) {
        for (int i = 1; i < tableData!.length; i++) {
          final row = tableData![i];
          if (row.length > entryPriceIndex && row.length > positionSizeIndex) {
            try {
              final entryPrice =
                  double.tryParse(row[entryPriceIndex].toString()) ?? 0.0;
              final positionSize =
                  int.tryParse(row[positionSizeIndex].toString()) ?? 0;

              if (entryPrice > 0 && positionSize > 0) {
                totalInvestment += entryPrice * positionSize;
                totalTrades++;
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      log('Error calculating summary: $e');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey300, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (totalTrades > 0) ...[
            Row(
              children: [
                Text(
                  'Total Trades: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey800,
                  ),
                ),
                Text(
                  '$totalTrades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Total Investment: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey800,
                  ),
                ),
                Text(
                  '\$${totalInvestment.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'No investment data found in this Excel file',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }
}
