import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

/// A widget to display connection status indicator
class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const ConnectionIndicator({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.connected : AppColors.disconnected;
    return Container(
      width: UIConstants.connectionIndicatorSize,
      height: UIConstants.connectionIndicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: UIConstants.elevationL,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
