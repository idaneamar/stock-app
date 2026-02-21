import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class TradeInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const TradeInfoColumn({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.fontM,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: UIConstants.fontL,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}
