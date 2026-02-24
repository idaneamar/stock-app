import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/formatters/number_format.dart';

class OrderPrepareSummaryBar extends StatelessWidget {
  final int totalOrders;
  final double totalInvestment;

  const OrderPrepareSummaryBar({
    super.key,
    required this.totalOrders,
    required this.totalInvestment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.totalOrders} $totalOrders',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                '${AppStrings.totalInvestment} ${formatUsd(totalInvestment, fractionDigits: 2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
