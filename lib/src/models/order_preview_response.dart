class OrderPreviewResponse {
  final bool success;
  final int status;
  final String message;
  final OrderPreviewBundle data;

  OrderPreviewResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderPreviewResponse.fromJson(Map<String, dynamic> json) {
    return OrderPreviewResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: OrderPreviewBundle.fromJson(json['data'] ?? {}),
    );
  }
}

class OrderPreviewBundle {
  final int scanId;
  final double? portfolioSize;
  final double? riskPerTrade;
  final int? maxSharesPerOrder;
  final OrderPreviewSection analysis;

  OrderPreviewBundle({
    required this.scanId,
    this.portfolioSize,
    this.riskPerTrade,
    this.maxSharesPerOrder,
    required this.analysis,
  });

  factory OrderPreviewBundle.fromJson(Map<String, dynamic> json) {
    final scanId = json['scan_id'] ?? 0;
    final portfolioSize =
        json['portfolio_size'] == null
            ? null
            : (json['portfolio_size'] as num).toDouble();
    final riskPerTrade =
        json['risk_per_trade'] == null
            ? null
            : (json['risk_per_trade'] as num).toDouble();
    final maxSharesPerOrder =
        json['max_shares_per_order'] is int
            ? json['max_shares_per_order'] as int
            : null;

    final analysis = json['analysis'];
    OrderPreviewSection unified;

    // New unified format: data.analysis is a single section with `orders`.
    if (analysis is Map<String, dynamic>) {
      if (analysis['orders'] is List) {
        unified = OrderPreviewSection.fromJson(analysis, label: 'Analysis');
      } else {
        // Backward compatibility: merge legacy results/suggestions sections into one list.
        final resultsJson = analysis['results'];
        final suggestionsJson = analysis['suggestions'];
        final resultsSection = OrderPreviewSection.fromJson(
          resultsJson is Map<String, dynamic> ? resultsJson : const {},
          label: 'Results',
        );
        final suggestionsSection = OrderPreviewSection.fromJson(
          suggestionsJson is Map<String, dynamic> ? suggestionsJson : const {},
          label: 'Suggestions',
        );
        final mergedOrders = <OrderItem>[
          ...resultsSection.orders,
          ...suggestionsSection.orders,
        ];
        unified = OrderPreviewSection(
          label: 'Analysis',
          totalOrders: mergedOrders.length,
          originalTotalInvestment:
              resultsSection.originalTotalInvestment +
              suggestionsSection.originalTotalInvestment,
          orders: mergedOrders,
        );
      }
    } else {
      // Legacy fallback: data.orders (single list); treat it as analysis.
      unified = OrderPreviewSection.fromJson(json, label: 'Analysis');
    }

    return OrderPreviewBundle(
      scanId: scanId,
      portfolioSize: portfolioSize,
      riskPerTrade: riskPerTrade,
      maxSharesPerOrder: maxSharesPerOrder,
      analysis: unified,
    );
  }
}

class OrderPreviewSection {
  final String label;
  final int totalOrders;
  final double originalTotalInvestment;
  final List<OrderItem> orders;

  OrderPreviewSection({
    required this.label,
    required this.totalOrders,
    required this.originalTotalInvestment,
    required this.orders,
  });

  factory OrderPreviewSection.empty({required String label}) {
    return OrderPreviewSection(
      label: label,
      totalOrders: 0,
      originalTotalInvestment: 0.0,
      orders: const [],
    );
  }

  factory OrderPreviewSection.fromJson(
    Map<String, dynamic> json, {
    required String label,
  }) {
    return OrderPreviewSection(
      label: label,
      totalOrders: json['total_orders'] ?? 0,
      originalTotalInvestment:
          (json['original_total_investment'] ?? 0).toDouble(),
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String symbol;
  final double entryPrice;
  final String recommendation;
  int originalPositionSize;
  final int calculatedPositionSize;
  int currentPositionSize;
  final int defaultPositionSize;
  final double defaultInvestment;
  final double stopLoss;
  final double takeProfit;
  final String exitDate;
  final String strategy;
  final double riskPerShare;
  double originalInvestment;
  final double calculatedInvestment;
  double currentInvestment;

  OrderItem({
    required this.symbol,
    required this.entryPrice,
    required this.recommendation,
    required this.originalPositionSize,
    required this.calculatedPositionSize,
    required this.currentPositionSize,
    required this.defaultPositionSize,
    required this.defaultInvestment,
    required this.stopLoss,
    required this.takeProfit,
    required this.exitDate,
    required this.strategy,
    required this.riskPerShare,
    required this.originalInvestment,
    required this.calculatedInvestment,
    required this.currentInvestment,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final originalPositionSize = json['original_position_size'] ?? 0;
    final originalInvestment = (json['original_investment'] ?? 0).toDouble();
    final entryPrice = (json['entry_price'] ?? 0).toDouble();
    final currentPositionSize =
        (json['current_position_size'] ?? json['calculated_position_size'] ?? 0)
            as int;
    final currentInvestmentValue =
        json['current_investment'] == null
            ? entryPrice * currentPositionSize
            : (json['current_investment'] as num).toDouble();

    return OrderItem(
      symbol: json['symbol'] ?? '',
      entryPrice: entryPrice,
      recommendation: json['recommendation'] ?? '',
      originalPositionSize: originalPositionSize,
      calculatedPositionSize: json['calculated_position_size'] ?? 0,
      currentPositionSize: currentPositionSize,
      defaultPositionSize: currentPositionSize,
      defaultInvestment: currentInvestmentValue,
      stopLoss: (json['stop_loss'] ?? 0).toDouble(),
      takeProfit: (json['take_profit'] ?? 0).toDouble(),
      exitDate: json['exit_date'] ?? '',
      strategy: json['strategy'] ?? '',
      riskPerShare: (json['risk_per_share'] ?? 0).toDouble(),
      originalInvestment: originalInvestment,
      calculatedInvestment: (json['calculated_investment'] ?? 0).toDouble(),
      currentInvestment: currentInvestmentValue,
    );
  }

  void updatePositionSize(int newSize) {
    currentPositionSize = newSize;
    currentInvestment = entryPrice * newSize;
  }

  void updateOriginalPositionSize(int newSize) {
    originalPositionSize = newSize;
    originalInvestment = entryPrice * newSize;
  }

  void resetToDefault() {
    currentPositionSize = defaultPositionSize;
    currentInvestment = defaultInvestment;
  }
}
