import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'dart:developer';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess({
    required String message,
    String? title,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSnackbar(
      title: title ?? AppStrings.success,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  static void showError({
    required String message,
    String? title,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSnackbar(
      title: title ?? AppStrings.error,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      duration: duration,
    );
  }

  static void showWarning({
    required String message,
    String? title,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
      duration: duration,
    );
  }

  static void showInfo({
    required String message,
    String? title,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info,
      duration: duration,
    );
  }

  static void _showSnackbar({
    String? title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    final type = backgroundColor == AppColors.error
        ? UiMessageType.error
        : (backgroundColor == AppColors.success
            ? UiMessageType.success
            : UiMessageType.info);

    final context = Get.context;
    if (context == null) {
      log('${title ?? ''} $message');
      return;
    }

    UiFeedback.showSnackBar(
      context,
      message: title == null ? message : '$title: $message',
      type: type,
    );
  }

  static void showSimpleSuccess(
    BuildContext context, {
    required String message,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSimpleSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  static void showSimpleError(
    BuildContext context, {
    required String message,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSimpleSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      duration: duration,
    );
  }

  static void showSimpleWarning(
    BuildContext context, {
    required String message,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSimpleSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
      duration: duration,
    );
  }

  static void showSimpleInfo(
    BuildContext context, {
    required String message,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    _showSimpleSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info,
      duration: duration,
    );
  }

  static void _showSimpleSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = UIConstants.snackbarNormal,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: UIConstants.spacingM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusS),
        ),
        duration: duration,
      ),
    );
  }
}
