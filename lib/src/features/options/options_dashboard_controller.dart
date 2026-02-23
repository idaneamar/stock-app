import 'package:get/get.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';

enum OptionsLoadState { idle, loading, success, error }

class OptionsDashboardController extends GetxController {
  final OptionsApiService _service = OptionsApiService();

  final Rx<OptionsLoadState> loadState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> statusState = OptionsLoadState.idle.obs;
  final Rx<OptionsLoadState> executeState = OptionsLoadState.idle.obs;

  final RxList<OptionsRecommendation> recommendations =
      <OptionsRecommendation>[].obs;
  final Rxn<OptionsStatus> status = Rxn<OptionsStatus>();
  final RxString currentDate = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString executeMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecommendations();
    fetchStatus();
  }

  Future<void> fetchRecommendations({String? date}) async {
    loadState.value = OptionsLoadState.loading;
    errorMessage.value = '';
    try {
      final result = await _service.getRecommendations(date: date);
      recommendations.assignAll(result.recommendations);
      currentDate.value = result.date ?? '';
      loadState.value = OptionsLoadState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      loadState.value = OptionsLoadState.error;
    }
  }

  Future<void> fetchStatus() async {
    statusState.value = OptionsLoadState.loading;
    try {
      final s = await _service.getStatus();
      status.value = s;
      statusState.value = OptionsLoadState.success;
    } catch (e) {
      statusState.value = OptionsLoadState.error;
    }
  }

  void refresh() {
    fetchRecommendations();
    fetchStatus();
  }

  Future<bool> executeAll({bool dryRun = false}) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        dryRun: dryRun,
      );
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value = OptionsLoadState.success;
      return result['ok'] == true;
    } catch (e) {
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return false;
    }
  }

  Future<bool> executeSingle(
    OptionsRecommendation rec, {
    bool dryRun = false,
  }) async {
    executeState.value = OptionsLoadState.loading;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: currentDate.value.isNotEmpty ? currentDate.value : null,
        tickers: [rec.ticker],
        dryRun: dryRun,
      );
      executeMessage.value = (result['message'] as String?) ?? 'Done';
      executeState.value = OptionsLoadState.success;
      return result['ok'] == true;
    } catch (e) {
      executeMessage.value = e.toString();
      executeState.value = OptionsLoadState.error;
      return false;
    }
  }

  Future<void> triggerRunOptsp() async {
    loadState.value = OptionsLoadState.loading;
    try {
      await _service.triggerRunOptsp();
      await Future.delayed(const Duration(seconds: 2));
      await fetchRecommendations();
    } catch (e) {
      errorMessage.value = e.toString();
      loadState.value = OptionsLoadState.error;
    }
  }
}
