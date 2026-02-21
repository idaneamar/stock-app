import 'package:flutter/material.dart';
import 'package:stock_app/src/features/stock_list/order_prepare_controller.dart';
import 'package:stock_app/src/features/stock_list/widgets/order_prepare_header.dart';
import 'package:stock_app/src/features/stock_list/widgets/order_prepare_orders_list.dart';
import 'package:stock_app/src/features/stock_list/widgets/order_prepare_summary_bar.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class AnalysisOrderPrepareScreen extends StatefulWidget {
  final int scanId;

  const AnalysisOrderPrepareScreen({super.key, required this.scanId});

  @override
  State<AnalysisOrderPrepareScreen> createState() =>
      _AnalysisOrderPrepareScreenState();
}

class _AnalysisOrderPrepareScreenState extends State<AnalysisOrderPrepareScreen> {
  late final OrderPrepareController controller;

  @override
  void initState() {
    super.initState();
    controller = OrderPrepareController(scanId: widget.scanId)..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              AppStrings.analysisOrderPrepare,
              style: TextStyle(color: AppColors.white),
            ),
            centerTitle: true,
            backgroundColor: AppColors.black,
            iconTheme: const IconThemeData(color: AppColors.white),
            actions: [
              IconButton(
                tooltip: AppStrings.refresh,
                onPressed: controller.isLoading ? null : controller.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Container(
            color: AppColors.grey50,
            padding: AppPadding.allL,
            child: controller.isLoading
                ? const LoadingWidget(color: AppColors.black)
                : controller.error.isNotEmpty
                    ? ErrorStateWidget(
                        errorMessage: controller.error,
                        onRetry: controller.load,
                      )
                    : _Content(controller: controller),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final OrderPrepareController controller;

  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalInvestment = controller.totalInvestment(controller.orders);
    return Column(
      children: [
        OrderPrepareHeader(scanId: controller.scanId),
        const SizedBox(height: UIConstants.spacingM),
        OrderPrepareSummaryBar(
          totalOrders: controller.orders.length,
          totalInvestment: totalInvestment,
        ),
        const SizedBox(height: UIConstants.spacingM),
        Expanded(
          child: OrderPrepareOrdersList(
            orders: controller.orders,
            ctrls: controller.ctrls,
            onChanged: (i) => controller.updateSize(index: i),
            onReset: (i) => controller.reset(index: i),
          ),
        ),
        const SizedBox(height: UIConstants.spacingM),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.isPlacing
                    ? null
                    : () => controller.placeOrders(context, controller.orders),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.grey,
            ),
            child:
                controller.isPlacing
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(AppStrings.placingOrder),
                      ],
                    )
                    : const Text(
                      AppStrings.placeOrder,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
