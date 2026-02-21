import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    this.title,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: UIConstants.iconHuge,
            color: AppColors.grey600,
          ),
          const SizedBox(height: UIConstants.spacingXL),
          Text(
            title ?? AppStrings.error,
            style: const TextStyle(
              fontSize: UIConstants.fontXXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingXXXL,
            ),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.fontL,
                color: AppColors.grey600,
              ),
            ),
          ),
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
              child: Text(retryButtonText ?? AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
