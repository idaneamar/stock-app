import 'package:flutter/material.dart';

/// Shared shell for the options dashboard to keep panel composition explicit.
class OptionsDashboardLayout extends StatelessWidget {
  final Widget header;
  final Widget healthBar;
  final Widget actionBar;
  final Widget body;

  const OptionsDashboardLayout({
    super.key,
    required this.header,
    required this.healthBar,
    required this.actionBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [header, healthBar, actionBar, Expanded(child: body)],
    );
  }
}
