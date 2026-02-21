import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';

class OrderPrepareInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const OrderPrepareInfoItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

