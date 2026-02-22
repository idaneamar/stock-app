import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/models/active_trades_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

/// Dialog for editing active trade details
class EditActiveTradeDialog extends StatefulWidget {
  final ActiveTrade trade;
  final Function(Map<String, dynamic> updates) onUpdate;

  const EditActiveTradeDialog({
    super.key,
    required this.trade,
    required this.onUpdate,
  });

  static void show(ActiveTrade trade, Function(Map<String, dynamic>) onUpdate) {
    final context = Get.context;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (_) => EditActiveTradeDialog(trade: trade, onUpdate: onUpdate),
    );
  }

  @override
  State<EditActiveTradeDialog> createState() => _EditActiveTradeDialogState();
}

class _EditActiveTradeDialogState extends State<EditActiveTradeDialog> {
  late final TextEditingController symbolController;
  late final TextEditingController recommendationController;
  late final TextEditingController entryPriceController;
  late final TextEditingController stopLossController;
  late final TextEditingController takeProfitController;
  late final TextEditingController positionSizeController;
  late final TextEditingController riskRewardController;
  late final TextEditingController strategyController;
  late final TextEditingController exitDateController;
  DateTime? selectedExitDate;

  @override
  void initState() {
    super.initState();
    symbolController = TextEditingController(text: widget.trade.symbol);
    recommendationController = TextEditingController(
      text: widget.trade.recommendation,
    );
    entryPriceController = TextEditingController(
      text: widget.trade.entryPrice.toString(),
    );
    stopLossController = TextEditingController(
      text: widget.trade.stopLoss.toString(),
    );
    takeProfitController = TextEditingController(
      text: widget.trade.takeProfit.toString(),
    );
    positionSizeController = TextEditingController(
      text: widget.trade.positionSize.toString(),
    );
    riskRewardController = TextEditingController(
      text: widget.trade.riskRewardRatio.toString(),
    );
    strategyController = TextEditingController(text: widget.trade.strategy);
    exitDateController = TextEditingController(text: widget.trade.exitDate);
    try {
      selectedExitDate = DateTime.parse(widget.trade.exitDate);
    } catch (e) {
      selectedExitDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    symbolController.dispose();
    recommendationController.dispose();
    entryPriceController.dispose();
    stopLossController.dispose();
    takeProfitController.dispose();
    positionSizeController.dispose();
    riskRewardController.dispose();
    strategyController.dispose();
    exitDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${AppStrings.editTrade} - ${widget.trade.symbol}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(symbolController, AppStrings.symbol),
              _buildTextField(
                recommendationController,
                AppStrings.recommendation,
              ),
              _buildTextField(
                entryPriceController,
                AppStrings.entryPrice,
                isNumber: true,
              ),
              _buildTextField(
                stopLossController,
                AppStrings.stopLoss,
                isNumber: true,
              ),
              _buildTextField(
                takeProfitController,
                AppStrings.takeProfit,
                isNumber: true,
              ),
              _buildTextField(
                positionSizeController,
                AppStrings.positionSize,
                isNumber: true,
              ),
              _buildTextField(
                riskRewardController,
                AppStrings.riskRewardRatio,
                isNumber: true,
              ),
              _buildTextField(strategyController, AppStrings.strategy),
              _buildDateField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _onUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
          ),
          child: Text(AppStrings.updateTrade),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.paddingM),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: exitDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: AppStrings.exitDate,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedExitDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) {
          setState(() {
            selectedExitDate = picked;
            exitDateController.text =
                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }

  void _onUpdate() {
    final updates = {
      "symbol": symbolController.text,
      "recommendation": recommendationController.text,
      "entry_price": double.tryParse(entryPriceController.text) ?? 0.0,
      "stop_loss": double.tryParse(stopLossController.text) ?? 0.0,
      "take_profit": double.tryParse(takeProfitController.text) ?? 0.0,
      "position_size": int.tryParse(positionSizeController.text) ?? 0,
      "risk_reward_ratio": double.tryParse(riskRewardController.text) ?? 0.0,
      "entry_date": widget.trade.entryDate,
      "exit_date": exitDateController.text,
      "strategy": strategyController.text,
    };
    Navigator.of(context).pop();
    widget.onUpdate(updates);
  }
}
