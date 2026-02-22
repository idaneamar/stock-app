import 'package:flutter/material.dart';
import 'package:stock_app/src/features/stock_list/widgets/order_prepare_order_card.dart';
import 'package:stock_app/src/models/order_preview_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';

class OrderPrepareOrdersList extends StatelessWidget {
  final List<OrderItem> orders;
  final List<TextEditingController> ctrls;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onReset;

  const OrderPrepareOrdersList({
    super.key,
    required this.orders,
    required this.ctrls,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(title: AppStrings.noOrdersFound);
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: UIConstants.spacingM),
      itemBuilder: (context, index) {
        final order = orders[index];
        final ctrl =
            index < ctrls.length ? ctrls[index] : TextEditingController();
        return OrderPrepareOrderCard(
          order: order,
          index: index,
          controller: ctrl,
          onChanged: () => onChanged(index),
          onReset: () => onReset(index),
        );
      },
    );
  }
}
