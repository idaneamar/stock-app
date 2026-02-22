import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stock_app/src/models/order_preview_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';

class OrderPrepareController extends ChangeNotifier {
  final ApiService _apiService;
  final int scanId;

  bool isLoading = true;
  bool isPlacing = false;
  String error = '';

  OrderPreviewBundle? preview;
  final List<OrderItem> orders = [];
  final List<TextEditingController> ctrls = [];

  OrderPrepareController({required this.scanId, ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  @override
  void dispose() {
    for (final c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final response = await _apiService.getOrderPreview(scanId: scanId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final parsed = OrderPreviewResponse.fromJson(response.data);
        preview = parsed.data;
        _setOrders(parsed.data.analysis.orders);
      } else {
        error = response.data['message'] ?? AppStrings.failedToLoadOrderPreview;
      }
    } catch (e) {
      log('Error loading order preview: $e');
      error = '${AppStrings.failedToLoadOrderPreview}: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _setOrders(List<OrderItem> orders) {
    for (final c in ctrls) {
      c.dispose();
    }
    ctrls.clear();
    this.orders
      ..clear()
      ..addAll(orders);

    ctrls.addAll(
      this.orders.map(
        (o) => TextEditingController(text: o.currentPositionSize.toString()),
      ),
    );
  }

  double totalInvestment(List<OrderItem> orders) =>
      orders.fold(0.0, (sum, o) => sum + o.currentInvestment);

  void updateSize({required int index}) {
    if (index < 0 || index >= orders.length || index >= ctrls.length) return;

    final parsed =
        int.tryParse(ctrls[index].text) ?? orders[index].currentPositionSize;
    orders[index].updatePositionSize(parsed);
    notifyListeners();
  }

  void reset({required int index}) {
    if (index < 0 || index >= orders.length || index >= ctrls.length) return;

    orders[index].resetToDefault();
    ctrls[index].text = orders[index].currentPositionSize.toString();
    notifyListeners();
  }

  Future<void> placeOrders(BuildContext context, List<OrderItem> orders) async {
    if (orders.isEmpty) {
      UiFeedback.showSnackBar(context, message: AppStrings.noOrdersToPlace);
      return;
    }
    if (isPlacing) return;

    isPlacing = true;
    notifyListeners();

    try {
      final payload =
          orders
              .map(
                (o) => {
                  'symbol': o.symbol,
                  'position_size': o.currentPositionSize,
                },
              )
              .toList();

      final response = await _apiService.placeModifiedOrders(
        scanId: scanId,
        modifiedOrders: payload,
      );

      if (!context.mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        UiFeedback.showSnackBar(
          context,
          message:
              response.data['message'] ?? AppStrings.orderPlacedSuccessfully,
          type: UiMessageType.success,
        );
      } else {
        UiFeedback.showSnackBar(
          context,
          message: response.data['message'] ?? AppStrings.failedToPlaceOrder,
          type: UiMessageType.error,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      UiFeedback.showSnackBar(
        context,
        message: '${AppStrings.failedToPlaceOrder}: $e',
        type: UiMessageType.error,
      );
    } finally {
      isPlacing = false;
      notifyListeners();
    }
  }
}
