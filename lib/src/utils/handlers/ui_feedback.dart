import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';

enum UiMessageType { success, error, info }

class UiFeedback {
  static void showSnackBar(
    BuildContext? context, {
    required String message,
    UiMessageType type = UiMessageType.info,
  }) {
    if (context == null) {
      log(message);
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      log(message);
      return;
    }

    final backgroundColor = switch (type) {
      UiMessageType.success => AppColors.success,
      UiMessageType.error => AppColors.error,
      UiMessageType.info => AppColors.blue,
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
