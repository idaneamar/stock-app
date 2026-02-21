import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class TradeDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const TradeDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontL,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: UIConstants.fontL,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
