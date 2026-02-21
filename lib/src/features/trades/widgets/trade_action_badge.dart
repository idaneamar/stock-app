import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class TradeActionBadge extends StatelessWidget {
  final String action;
  final bool isSmall;

  const TradeActionBadge({
    super.key,
    required this.action,
    this.isSmall = false,
  });

  bool get _isBuy => action.toLowerCase() == 'buy';

  Color get _color => _isBuy ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? UIConstants.paddingS : UIConstants.paddingS,
        vertical: isSmall ? UIConstants.paddingXS : UIConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusXS),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        action.toUpperCase(),
        style: TextStyle(
          fontSize: isSmall ? UIConstants.fontS : UIConstants.fontM,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}
