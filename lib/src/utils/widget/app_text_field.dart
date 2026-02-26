import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDecimal;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool isCompact;
  final int maxLines;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isDecimal = false,
    this.keyboardType,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isCompact = false,
    this.maxLines = 1,
    this.textInputAction,
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
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        isDense: isCompact,
        contentPadding:
            isCompact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
