import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

/// A widget for date range filtering
class DateFilterWidget extends StatelessWidget {
  final String dateRangeText;
  final bool hasDateFilter;
  final bool canDownload;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClear;
  final VoidCallback onDownload;

  const DateFilterWidget({
    super.key,
    required this.dateRangeText,
    required this.hasDateFilter,
    required this.canDownload,
    required this.onSelectDateRange,
    required this.onClear,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPadding.allL,
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: UIConstants.spacingL),
          Text(
            dateRangeText,
            style: TextStyle(fontSize: UIConstants.fontL, color: AppColors.grey600),
          ),
          const SizedBox(height: UIConstants.spacingL),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.date_range, color: AppColors.blue, size: UIConstants.iconM),
        const SizedBox(width: UIConstants.spacingM),
        Text(
          AppStrings.dateFilter,
          style: const TextStyle(
            fontSize: UIConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const Spacer(),
        if (hasDateFilter)
          TextButton(
            onPressed: onClear,
            child: Text(
              AppStrings.clear,
              style: TextStyle(color: AppColors.error, fontSize: UIConstants.fontM),
            ),
          ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onSelectDateRange,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingXXL,
                vertical: UIConstants.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
            ),
            child: Text(AppStrings.selectDateRange),
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canDownload ? onDownload : null,
            icon: const Icon(Icons.download, size: UIConstants.iconS),
            label: Text(AppStrings.downloadAllRecommendation),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingM,
                vertical: UIConstants.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              disabledBackgroundColor: AppColors.grey,
              disabledForegroundColor: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
