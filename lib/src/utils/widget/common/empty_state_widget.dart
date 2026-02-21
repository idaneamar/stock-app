import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: UIConstants.iconHuge, color: AppColors.grey),
          const SizedBox(height: UIConstants.spacingXL),
          Text(
            title,
            style: const TextStyle(
              fontSize: UIConstants.fontXXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: UIConstants.spacingM),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingXXXL,
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: UIConstants.fontL,
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: UIConstants.spacingXXL),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                padding: UIConstants.buttonPadding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusS),
                ),
              ),
              child: Text(retryButtonText ?? AppStrings.refresh),
            ),
          ],
        ],
      ),
    );
  }
}
