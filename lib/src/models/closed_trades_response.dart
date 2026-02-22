class ClosedTradesResponse {
  final bool success;
  final int status;
  final String message;
  final ClosedTradesData data;

  ClosedTradesResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ClosedTradesResponse.fromJson(Map<String, dynamic> json) {
    return ClosedTradesResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: ClosedTradesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ClosedTradesData {
  final List<ClosedTrade> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  ClosedTradesData({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ClosedTradesData.fromJson(Map<String, dynamic> json) {
    return ClosedTradesData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ClosedTrade.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalPages: json['total_pages'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}

class ClosedTrade {
  final int id;
  final String symbol;
  final String action;
  final int quantity;
  final double entryPrice;
  final double exitPrice;
  final String entryDate;
  final String exitDate;
  final String closeReason;
  final String strategy;
  final int scanId;
  final String analysisType;
  final double stopLoss;
  final double takeProfit;
  final String targetDate;
  final String createdAt;

  ClosedTrade({
    required this.id,
    required this.symbol,
    required this.action,
    required this.quantity,
    required this.entryPrice,
    required this.exitPrice,
    required this.entryDate,
    required this.exitDate,
    required this.closeReason,
    required this.strategy,
    required this.scanId,
    required this.analysisType,
    required this.stopLoss,
    required this.takeProfit,
    required this.targetDate,
    required this.createdAt,
  });

  factory ClosedTrade.fromJson(Map<String, dynamic> json) {
    return ClosedTrade(
      id: json['id'] ?? 0,
      symbol: json['symbol'] ?? '',
      action: json['action'] ?? '',
      quantity: json['quantity'] ?? 0,
      entryPrice: (json['entry_price'] ?? 0).toDouble(),
      exitPrice: (json['exit_price'] ?? 0).toDouble(),
      entryDate: json['entry_date'] ?? '',
      exitDate: json['exit_date'] ?? '',
      closeReason: json['close_reason'] ?? '',
      strategy: json['strategy'] ?? '',
      scanId: json['scan_id'] ?? 0,
      analysisType: json['analysis_type'] ?? '',
      stopLoss: (json['stop_loss'] ?? 0).toDouble(),
      takeProfit: (json['take_profit'] ?? 0).toDouble(),
      targetDate: json['target_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'action': action,
      'quantity': quantity,
      'entry_price': entryPrice,
      'exit_price': exitPrice,
      'entry_date': entryDate,
      'exit_date': exitDate,
      'close_reason': closeReason,
      'strategy': strategy,
      'scan_id': scanId,
      'analysis_type': analysisType,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'target_date': targetDate,
      'created_at': createdAt,
    };
  }

  // Calculate profit/loss
  double get profitLoss {
    if (action.toLowerCase() == 'buy') {
      return (exitPrice - entryPrice) * quantity;
    } else {
      return (entryPrice - exitPrice) * quantity;
    }
  }

  // Calculate profit/loss percentage
  double get profitLossPercentage {
    if (entryPrice == 0) return 0.0;
    if (action.toLowerCase() == 'buy') {
      return ((exitPrice - entryPrice) / entryPrice) * 100;
    } else {
      return ((entryPrice - exitPrice) / entryPrice) * 100;
    }
  }

  // Check if trade was profitable
  bool get isProfitable => profitLoss > 0;
}
