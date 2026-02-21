import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

abstract class AppTextStyles {
  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: UIConstants.fontHeading,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: UIConstants.fontXXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: UIConstants.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.normal,
    color: AppColors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.normal,
    color: AppColors.black87,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.w600,
    color: AppColors.black87,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: UIConstants.fontS,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
  );

  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Caption text
  static const TextStyle caption = TextStyle(
    fontSize: UIConstants.fontS,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: UIConstants.fontS,
    fontWeight: FontWeight.bold,
    color: AppColors.grey600,
  );

  // AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  // Card title
  static const TextStyle cardTitle = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Card subtitle
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
  );

  // Price/Value text
  static const TextStyle price = TextStyle(
    fontSize: UIConstants.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Status text
  static const TextStyle statusSuccess = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );

  static const TextStyle statusError = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  );

  static const TextStyle statusWarning = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.bold,
    color: AppColors.warning,
  );

  // Chip text
  static const TextStyle chipText = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.bold,
  );

  // Link text
  static const TextStyle link = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.w500,
    color: AppColors.blue,
    decoration: TextDecoration.underline,
  );

  // Empty state text
  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: UIConstants.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.grey,
  );

  static const TextStyle emptyStateSubtitle = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
  );

  // Input text
  static const TextStyle inputText = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.normal,
    color: AppColors.grey400,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: UIConstants.fontM,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  // Dialog text
  static const TextStyle dialogTitle = TextStyle(
    fontSize: UIConstants.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle dialogContent = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.normal,
    color: AppColors.grey800,
  );

  // Snackbar text
  static const TextStyle snackbarText = TextStyle(
    fontSize: UIConstants.fontL,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  static const TextStyle snackbarTitle = TextStyle(
    fontSize: UIConstants.fontXL,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}

extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.normal);
}
