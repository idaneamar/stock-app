import 'package:flutter/material.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/formatters/date_formatter.dart';

/// A card widget to display scan history item
class ScanHistoryCard extends StatelessWidget {
  final ScanHistoryData scan;
  final int? scanProgress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ScanHistoryCard({
    super.key,
    required this.scan,
    this.scanProgress,
    this.onTap,
    this.onLongPress,
  });

  Color get _borderColor {
    switch (scan.status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
      case 'analyzing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData get _statusIcon {
    switch (scan.status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
      case 'analyzing':
        return Icons.access_time;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String get _formattedDate => DateFormatter.formatDateTime(scan.createdAt);

  bool get _isCompleted => scan.status.toLowerCase() == 'completed';
  bool get _isFailed => scan.status.toLowerCase() == 'failed';
  bool get _isInProgress =>
      scan.status.toLowerCase() == 'in_progress' ||
      scan.status.toLowerCase() == 'analyzing';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: UIConstants.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        side: BorderSide(color: _borderColor, width: UIConstants.borderWidthThick),
      ),
      child: GestureDetector(
        onLongPress: _isInProgress ? null : onLongPress,
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          onTap: _isCompleted ? onTap : null,
          child: Padding(
            padding: AppPadding.allL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: UIConstants.spacingL),
                _buildDateAndStocks(),
                if (scanProgress != null) _buildProgressBar(),
                if (_isCompleted && scan.stockSymbols.isNotEmpty) _buildStockSymbols(),
                if (_isFailed && scan.errorMessage != null) _buildErrorMessage(),
                if (_isCompleted) _buildTapToViewHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(_statusIcon, color: _borderColor, size: UIConstants.iconM),
        const SizedBox(width: UIConstants.spacingM),
        Text(
          'Scan #${scan.id}',
          style: const TextStyle(fontSize: UIConstants.fontXL, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: UIConstants.chipPadding,
          decoration: BoxDecoration(
            color: _borderColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            border: Border.all(color: _borderColor),
          ),
          child: Text(
            scan.status.toUpperCase(),
            style: TextStyle(
              color: _borderColor,
              fontSize: UIConstants.fontM,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndStocks() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: UIConstants.iconXS, color: AppColors.grey600),
        const SizedBox(width: UIConstants.spacingS),
        Text(_formattedDate, style: TextStyle(fontSize: UIConstants.fontM, color: AppColors.grey600)),
        const Spacer(),
        Icon(Icons.trending_up, size: UIConstants.iconXS, color: AppColors.grey600),
        const SizedBox(width: UIConstants.spacingS),
        Text(
          '${scan.totalFound} stocks found',
          style: TextStyle(fontSize: UIConstants.fontM, color: AppColors.grey600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        const SizedBox(height: UIConstants.spacingL),
        Row(
          children: [
            Icon(Icons.search, size: UIConstants.iconS, color: AppColors.blue),
            const SizedBox(width: UIConstants.spacingS),
            Text(
              'Scanning: $scanProgress%',
              style: TextStyle(fontSize: UIConstants.fontM, color: AppColors.blue700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        LinearProgressIndicator(
          value: scanProgress! / 100,
          backgroundColor: AppColors.grey300,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      ],
    );
  }

  Widget _buildStockSymbols() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: UIConstants.spacingL),
        const Text(
          'Stock Symbols:',
          style: TextStyle(fontSize: UIConstants.fontM, fontWeight: FontWeight.w600, color: AppColors.black87),
        ),
        const SizedBox(height: UIConstants.spacingS),
        Wrap(
          spacing: UIConstants.spacingS,
          runSpacing: UIConstants.spacingS,
          children: scan.stockSymbols.take(10).map<Widget>((symbol) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingS, vertical: UIConstants.paddingXS),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Text(symbol.ticker, style: const TextStyle(fontSize: UIConstants.fontS, fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
        if (scan.stockSymbols.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: UIConstants.paddingXS),
            child: Text(
              '...and ${scan.stockSymbols.length - 10} more',
              style: TextStyle(fontSize: UIConstants.fontS, color: AppColors.grey600, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.marginL),
      padding: AppPadding.allS,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: UIConstants.iconS),
          const SizedBox(width: UIConstants.spacingS),
          Expanded(
            child: Text(scan.errorMessage!, style: const TextStyle(fontSize: UIConstants.fontM, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildTapToViewHint() {
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.marginL),
      padding: UIConstants.chipPadding,
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app, color: AppColors.blue, size: UIConstants.iconXS),
          const SizedBox(width: UIConstants.spacingS),
          Text(
            'Tap to view stocks',
            style: TextStyle(fontSize: UIConstants.fontS, color: AppColors.blue700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
