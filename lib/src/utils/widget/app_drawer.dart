import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/widget/drawer/app_drawer_content.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onMenuSelected;

  const AppDrawer({super.key, this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: AppDrawerContent(onMenuSelected: onMenuSelected));
  }
}

