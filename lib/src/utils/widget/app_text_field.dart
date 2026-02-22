import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDecimal;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isDecimal = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType =
        keyboardType ??
        (isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number);
    return TextField(
      controller: controller,
      keyboardType: effectiveKeyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
