import 'package:get/get.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';

enum OptionsHistoryLoadState { idle, loading, success, error }

class OptionsHistoryController extends GetxController {
  final OptionsApiService _service = OptionsApiService();

  final Rx<OptionsHistoryLoadState> datesState =
      OptionsHistoryLoadState.idle.obs;
  final Rx<OptionsHistoryLoadState> recsState =
      OptionsHistoryLoadState.idle.obs;

  final RxList<String> availableDates = <String>[].obs;
  final RxList<OptionsRecommendation> recommendations =
      <OptionsRecommendation>[].obs;
  final RxString selectedDate = ''.obs;
  final RxString filterTicker = ''.obs;
  final RxString errorMessage = ''.obs;

  // Execute state for history screen
  final RxBool isExecuting = false.obs;
  final RxString executeMessage = ''.obs;
  final RxBool executeOk = false.obs;

  List<OptionsRecommendation> get filteredRecommendations {
    final q = filterTicker.value.trim().toUpperCase();
    if (q.isEmpty) return recommendations;
    return recommendations
        .where((r) => r.ticker.toUpperCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadDates();
  }

  Future<void> _loadDates() async {
    datesState.value = OptionsHistoryLoadState.loading;
    try {
      final dates = await _service.getAvailableDates();
      availableDates.assignAll(dates);
      datesState.value = OptionsHistoryLoadState.success;
      if (dates.isNotEmpty) {
        await loadDate(dates.first);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      datesState.value = OptionsHistoryLoadState.error;
    }
  }

  Future<void> loadDate(String date) async {
    selectedDate.value = date;
    recsState.value = OptionsHistoryLoadState.loading;
    filterTicker.value = '';
    errorMessage.value = '';
    executeMessage.value = '';
    try {
      final result = await _service.getRecommendations(date: date);
      recommendations.assignAll(result.recommendations);
      recsState.value = OptionsHistoryLoadState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      recsState.value = OptionsHistoryLoadState.error;
    }
  }

  void navigateToPrevDate() {
    final dates = availableDates;
    if (dates.isEmpty) return;
    final idx = dates.indexOf(selectedDate.value);
    if (idx < dates.length - 1) loadDate(dates[idx + 1]);
  }

  void navigateToNextDate() {
    final dates = availableDates;
    if (dates.isEmpty) return;
    final idx = dates.indexOf(selectedDate.value);
    if (idx > 0) loadDate(dates[idx - 1]);
  }

  bool get hasPrev {
    final idx = availableDates.indexOf(selectedDate.value);
    return idx < availableDates.length - 1;
  }

  bool get hasNext {
    final idx = availableDates.indexOf(selectedDate.value);
    return idx > 0;
  }

  // ---------------------------------------------------------------------------
  // Execute (send to IBKR from history)
  // ---------------------------------------------------------------------------

  Future<void> executeAll() async {
    if (selectedDate.value.isEmpty) return;
    isExecuting.value = true;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: selectedDate.value,
      );
      final ok = result['ok'] == true;
      executeOk.value = ok;
      executeMessage.value =
          (result['message'] as String?) ?? (ok ? 'Done' : 'Failed');
    } catch (e) {
      executeOk.value = false;
      executeMessage.value = e.toString();
    } finally {
      isExecuting.value = false;
    }
  }

  Future<void> executeSingle(OptionsRecommendation rec) async {
    if (selectedDate.value.isEmpty) return;
    isExecuting.value = true;
    executeMessage.value = '';
    try {
      final result = await _service.executeRecommendations(
        recDate: selectedDate.value,
        tickers: [rec.ticker],
      );
      final ok = result['ok'] == true;
      executeOk.value = ok;
      executeMessage.value =
          (result['message'] as String?) ?? (ok ? 'Done' : 'Failed');
    } catch (e) {
      executeOk.value = false;
      executeMessage.value = e.toString();
    } finally {
      isExecuting.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<bool> deleteDate(String date) async {
    try {
      await _service.deleteRecommendationDate(date);
      // Remove from local list and navigate to next available date
      availableDates.remove(date);
      if (selectedDate.value == date) {
        if (availableDates.isNotEmpty) {
          await loadDate(availableDates.first);
        } else {
          selectedDate.value = '';
          recommendations.clear();
          recsState.value = OptionsHistoryLoadState.idle;
        }
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteRecommendation(OptionsRecommendation rec) async {
    try {
      await _service.deleteRecommendationTicker(selectedDate.value, rec.ticker);
      recommendations.removeWhere(
        (r) => r.ticker.toUpperCase() == rec.ticker.toUpperCase(),
      );
      // If file is now empty the server deleted it — remove date from list
      if (recommendations.isEmpty) {
        availableDates.remove(selectedDate.value);
        if (availableDates.isNotEmpty) {
          await loadDate(availableDates.first);
        } else {
          selectedDate.value = '';
          recsState.value = OptionsHistoryLoadState.idle;
        }
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  @override
  void refresh() => _loadDates();
}
