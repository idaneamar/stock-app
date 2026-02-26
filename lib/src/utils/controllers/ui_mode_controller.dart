import 'package:get/get.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';

enum UiMode { classic, simplified }

class UiModeController extends GetxController {
  final Rx<UiMode> mode = UiMode.simplified.obs;
  final RxBool isReady = false.obs;

  bool get isClassic => mode.value == UiMode.classic;
  bool get isSimplified => mode.value == UiMode.simplified;

  @override
  void onInit() {
    super.onInit();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final raw = await SharedPrefsService.getUiMode();
    mode.value = raw == 'classic' ? UiMode.classic : UiMode.simplified;
    isReady.value = true;
  }

  Future<void> setMode(UiMode nextMode) async {
    if (mode.value == nextMode) return;
    mode.value = nextMode;
    await SharedPrefsService.setUiMode(nextMode.name);
  }
}
