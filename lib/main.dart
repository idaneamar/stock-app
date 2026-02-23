import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/controllers/trading_mode_controller.dart';
import 'package:stock_app/src/utils/route/app_router.dart';

void main() {
  Get.put(TradingModeController(), permanent: true);
  runApp(const StockApp());
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Stock App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      initialRoute: Routes.login,
      getPages: getPages,
      unknownRoute: GetPage(
        name: Routes.notFound,
        page:
            () => const Scaffold(
              body: Center(child: Text("404 - Page not found")),
            ),
      ),
    );
  }
}
