import 'package:flutter/material.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class EditAnalysisTradeDialog extends StatefulWidget {
  final Trade trade;

  const EditAnalysisTradeDialog({super.key, required this.trade});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Trade trade,
  }) {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) => EditAnalysisTradeDialog(trade: trade),
    );
  }

  @override
  State<EditAnalysisTradeDialog> createState() => _EditAnalysisTradeDialogState();
}

class _EditAnalysisTradeDialogState extends State<EditAnalysisTradeDialog> {
  late final TextEditingController positionSizeController;
  late final TextEditingController exitDateController;
  DateTime? selectedExitDate;

  @override
  void initState() {
    super.initState();
    positionSizeController =
        TextEditingController(text: widget.trade.positionSize.toString());
    exitDateController = TextEditingController(text: widget.trade.exitDate);
    selectedExitDate = DateTime.tryParse(widget.trade.exitDate) ?? DateTime.now();
  }

  @override
  void dispose() {
    positionSizeController.dispose();
    exitDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${AppStrings.editTrade} - ${widget.trade.symbol}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: positionSizeController,
            decoration: const InputDecoration(
              labelText: AppStrings.positionSize,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: UIConstants.spacingM),
          TextField(
            controller: exitDateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: AppStrings.exitDate,
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickExitDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
          ),
          child: Text(AppStrings.update),
        ),
      ],
    );
  }

  Future<void> _pickExitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedExitDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;

    setState(() {
      selectedExitDate = picked;
      exitDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  void _submit() {
    final positionSize = int.tryParse(positionSizeController.text) ?? 0;
    if (positionSize <= 0) return;

    Navigator.of(context).pop({
      "symbol": widget.trade.symbol,
      "recommendation": widget.trade.recommendation,
      "entry_price": widget.trade.entryPrice,
      "stop_loss": widget.trade.stopLoss,
      "take_profit": widget.trade.takeProfit,
      "position_size": positionSize,
      "risk_reward_ratio": widget.trade.riskRewardRatio,
      "entry_date": widget.trade.entryDate,
      "exit_date": exitDateController.text,
      "strategy": widget.trade.strategy,
    });
  }
}

