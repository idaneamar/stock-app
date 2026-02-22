class OpenTradesResponse {
  final bool success;
  final int status;
  final String message;
  final OpenTradesData data;

  OpenTradesResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory OpenTradesResponse.fromJson(Map<String, dynamic> json) {
    return OpenTradesResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: OpenTradesData.fromJson(json['data'] ?? {}),
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

class OpenTradesData {
  final List<OpenTrade> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  OpenTradesData({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory OpenTradesData.fromJson(Map<String, dynamic> json) {
    return OpenTradesData(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OpenTrade.fromJson(item))
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

class OpenTrade {
  final int id;
  final String symbol;
  final String action;
  final int quantity;
  final double entryPrice;
  final String entryDate;
  final double stopLoss;
  final double takeProfit;
  final String targetDate;
  final int scanId;
  final String analysisType;
  final String strategy;
  final String updatedAt;

  OpenTrade({
    required this.id,
    required this.symbol,
    required this.action,
    required this.quantity,
    required this.entryPrice,
    required this.entryDate,
    required this.stopLoss,
    required this.takeProfit,
    required this.targetDate,
    required this.scanId,
    required this.analysisType,
    required this.strategy,
    required this.updatedAt,
  });

  factory OpenTrade.fromJson(Map<String, dynamic> json) {
    return OpenTrade(
      id: json['id'] ?? 0,
      symbol: json['symbol'] ?? '',
      action: json['action'] ?? '',
      quantity: json['quantity'] ?? 0,
      entryPrice: (json['entry_price'] ?? 0).toDouble(),
      entryDate: json['entry_date'] ?? '',
      stopLoss: (json['stop_loss'] ?? 0).toDouble(),
      takeProfit: (json['take_profit'] ?? 0).toDouble(),
      targetDate: json['target_date'] ?? '',
      scanId: json['scan_id'] ?? 0,
      analysisType: json['analysis_type'] ?? '',
      strategy: json['strategy'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'action': action,
      'quantity': quantity,
      'entry_price': entryPrice,
      'entry_date': entryDate,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'target_date': targetDate,
      'scan_id': scanId,
      'analysis_type': analysisType,
      'strategy': strategy,
      'updated_at': updatedAt,
    };
  }
}
