String formatNumberWithCommas(num value, {int fractionDigits = 0}) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final fixed = absValue.toStringAsFixed(fractionDigits);
  final parts = fixed.split('.');
  final intPart = parts[0];

  final withCommas = intPart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
  return '${isNegative ? '-' : ''}$withCommas$decimalPart';
}

String formatUsd(num value, {int fractionDigits = 0}) {
  return '\$${formatNumberWithCommas(value, fractionDigits: fractionDigits)}';
}

String normalizeNumberInput(String input) {
  return input.replaceAll(',', '').trim();
}
