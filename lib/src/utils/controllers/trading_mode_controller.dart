import 'package:get/get.dart';

enum TradingMode { stocks, options }

class TradingModeController extends GetxController {
  final Rx<TradingMode> mode = TradingMode.stocks.obs;

  bool get isStocks => mode.value == TradingMode.stocks;
  bool get isOptions => mode.value == TradingMode.options;

  void setMode(TradingMode newMode) {
    if (mode.value == newMode) return;
    mode.value = newMode;
  }
}
