import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stock_app/src/models/trade_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/file_helper.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:universal_html/html.dart' as html;

class AnalysisTradesController extends ChangeNotifier {
  final ApiService _apiService;

  TradeData tradeData;
  bool isBusy = false;
  bool isDownloading = false;
  String errorMessage = '';

  AnalysisTradesController({required this.tradeData, ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  double totalInvestment(List<Trade> trades) =>
      trades.fold(0.0, (sum, t) => sum + (t.entryPrice * t.positionSize));

  Future<void> refresh() async {
    if (isBusy) return;
    isBusy = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.getScanTrades(tradeData.scanId);
      if (response.statusCode == 200) {
        final parsed = TradeResponse.fromJson(response.data);
        tradeData = parsed.data;
      } else {
        errorMessage = AppStrings.failedToLoadScanData;
      }
    } catch (e) {
      log('Error refreshing trade data: $e');
      errorMessage = e.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> downloadExcel(BuildContext? context) async {
    if (isDownloading) return;
    isDownloading = true;
    notifyListeners();

    try {
      final response = await _apiService.getTradesExcel(
        scanId: tradeData.scanId,
      );
      if (response.statusCode != 200) {
        throw Exception(AppStrings.failedToDownloadExcelFile);
      }

      final bytes =
          response.data is List<int>
              ? response.data as List<int>
              : List<int>.from(response.data);
      final fileName = 'trades_${tradeData.scanId}.xlsx';

      if (kIsWeb) {
        final blob = html.Blob([
          bytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await FileHelper.saveFileToDownloads(bytes, fileName);
      }

      UiFeedback.showSnackBar(
        context,
        message: AppStrings.downloadStarted,
        type: UiMessageType.success,
      );
    } catch (e) {
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.errorDownloadingExcelFile} $e',
        type: UiMessageType.error,
      );
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> updateTrade(
    BuildContext? context,
    Map<String, dynamic> updates,
  ) async {
    isBusy = true;
    notifyListeners();
    try {
      final response = await _apiService.updateActiveTrades(
        scanId: tradeData.scanId,
        updates: [updates],
      );
      if (response.statusCode == 200) {
        await refresh();
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.tradeUpdatedSuccessfully,
          type: UiMessageType.success,
        );
      } else {
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.failedToUpdateTrade,
          type: UiMessageType.error,
        );
      }
    } catch (e) {
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.errorUpdatingTrade} $e',
        type: UiMessageType.error,
      );
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrade(BuildContext? context, String symbol) async {
    isBusy = true;
    notifyListeners();
    try {
      final response = await _apiService.deleteActiveTrade(
        scanId: tradeData.scanId,
        symbol: symbol,
      );
      if (response.statusCode == 200) {
        await refresh();
        UiFeedback.showSnackBar(
          context,
          message: '$symbol ${AppStrings.deletedSuccessfully}',
          type: UiMessageType.success,
        );
      } else {
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.failedToDeleteTrade,
          type: UiMessageType.error,
        );
      }
    } catch (e) {
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.errorDeletingTrade} $e',
        type: UiMessageType.error,
      );
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
