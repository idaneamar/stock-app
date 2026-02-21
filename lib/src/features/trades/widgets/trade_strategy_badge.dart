import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class TradeStrategyBadge extends StatelessWidget {
  final String strategy;
  final bool isSmall;

  const TradeStrategyBadge({
    super.key,
    required this.strategy,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? UIConstants.paddingS : UIConstants.paddingS,
        vertical: isSmall ? UIConstants.paddingXS : UIConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Text(
        strategy,
        style: TextStyle(
          fontSize: isSmall ? UIConstants.fontS : UIConstants.fontM,
          fontWeight: FontWeight.bold,
          color: AppColors.blue,
        ),
      ),
    );
  }
}
