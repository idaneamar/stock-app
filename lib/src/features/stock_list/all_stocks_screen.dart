// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/widget/app_drawer.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'dart:developer';
import 'package:universal_html/html.dart' as html;
import 'package:stock_app/src/utils/file_helper.dart';

class AllStocksScreen extends StatefulWidget {
  final List<StockSymbol> stockSymbols;
  final String scanId;

  const AllStocksScreen({
    super.key,
    required this.stockSymbols,
    required this.scanId,
  });

  @override
  State<AllStocksScreen> createState() => _AllStocksScreenState();
}

class _AllStocksScreenState extends State<AllStocksScreen> {
  final ApiService _apiService = ApiService();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Stocks',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child:
                _isDownloading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                    : TextButton(
                      onPressed:
                          () => _downloadAllScannedStocksExcel(widget.scanId),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Download all Scaned Stocks Excel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: AppColors.grey50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Stocks: ${widget.stockSymbols.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
            ),
            Expanded(
              child:
                  widget.stockSymbols.isEmpty
                      ? Center(
                        child: Text(
                          'No stocks found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey600,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: widget.stockSymbols.length,
                        itemBuilder: (context, index) {
                          return _buildDetailedStockCard(
                            widget.stockSymbols[index],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAllScannedStocksExcel(String scanId) async {
    try {
      setState(() {
        _isDownloading = true;
      });

      final response = await _apiService.getAllScannedStocksExcel(scanId);

      if (response.statusCode == 200) {
        log('Received Excel response for all scanned stocks');

        List<int> bytes;
        if (response.data is List<int>) {
          bytes = response.data as List<int>;
        } else if (response.data is Uint8List) {
          bytes = response.data as Uint8List;
        } else if (response.data is List) {
          bytes = List<int>.from(response.data);
        } else {
          throw Exception(
            'Unexpected response data type: ${response.data.runtimeType}',
          );
        }

        if (bytes.isEmpty) {
          throw Exception('Received empty Excel data');
        }

        if (kIsWeb) {
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor =
              html.document.createElement('a') as html.AnchorElement
                ..href = url
                ..style.display = 'none'
                ..download = 'All_Scanned_Stocks.xlsx';
          html.document.body?.children.add(anchor);
          anchor.click();
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        } else {
          // Save to Downloads folder on mobile
          await FileHelper.saveFileToDownloads(
            bytes,
            'All_Scanned_Stocks.xlsx',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? 'Excel file downloaded successfully'
                    : 'Excel file saved to Downloads folder',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Failed to download Excel file');
      }
    } catch (e) {
      log('Error downloading all scanned stocks Excel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading Excel file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildDetailedStockCard(StockSymbol stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ticker and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.ticker,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${stock.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Market metrics in a grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Market Cap',
                    _formatMarketCap(stock.marketCap),
                    Icons.account_balance,
                    AppColors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Volatility',
                    '${stock.volatility.toStringAsFixed(2)}%',
                    Icons.trending_up,
                    AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Avg Volume',
                    _formatVolume(stock.avgVolume),
                    Icons.bar_chart,
                    AppColors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Avg Transaction',
                    _formatCurrency(stock.avgTransactionValue),
                    Icons.monetization_on,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1e9) {
      return '\$${(marketCap / 1e9).toStringAsFixed(2)}B';
    } else if (marketCap >= 1e6) {
      return '\$${(marketCap / 1e6).toStringAsFixed(2)}M';
    } else if (marketCap >= 1e3) {
      return '\$${(marketCap / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${marketCap.toStringAsFixed(2)}';
  }

  String _formatVolume(double volume) {
    if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(2)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(2)}K';
    }
    return volume.toStringAsFixed(0);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1e6) {
      return '\$${(amount / 1e6).toStringAsFixed(2)}M';
    } else if (amount >= 1e3) {
      return '\$${(amount / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}
