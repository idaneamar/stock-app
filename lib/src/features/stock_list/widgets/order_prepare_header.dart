import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';

class OrderPrepareHeader extends StatelessWidget {
  final int scanId;

  const OrderPrepareHeader({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics, color: AppColors.blue, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.analysisOrderPrepare,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              '${AppStrings.scanPrefix}$scanId',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}

