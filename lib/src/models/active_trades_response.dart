class ActiveTradesResponse {
  final bool success;
  final int status;
  final String message;
  final ActiveTradesData data;

  ActiveTradesResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ActiveTradesResponse.fromJson(Map<String, dynamic> json) {
    return ActiveTradesResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: ActiveTradesData.fromJson(json['data'] ?? {}),
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

class ActiveTradesData {
  final int totalScans;
  final int totalTrades;
  final DateFilter dateFilter;
  final List<ActiveTrade> analysis;

  ActiveTradesData({
    required this.totalScans,
    required this.totalTrades,
    required this.dateFilter,
    required this.analysis,
  });

  factory ActiveTradesData.fromJson(Map<String, dynamic> json) {
    List<ActiveTrade> parseTrades(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => ActiveTrade.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (value is Map) {
        final items = value['items'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((e) => ActiveTrade.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    }

    // New unified format: `data.analysis` is a single list.
    // Backward compatibility: merge legacy results/suggestions.
    final rawAnalysis = json['analysis'];
    List<ActiveTrade> unified;
    if (rawAnalysis is List) {
      unified = parseTrades(rawAnalysis);
    } else if (rawAnalysis is Map) {
      unified = <ActiveTrade>[
        ...parseTrades(rawAnalysis['results']),
        ...parseTrades(rawAnalysis['suggestions']),
      ];
      if (unified.isEmpty) {
        unified = parseTrades(rawAnalysis);
      }
    } else {
      unified = <ActiveTrade>[
        ...parseTrades(json['trades']),
        ...parseTrades(json['suggestions']),
      ];
    }

    final totalTrades =
        (json['total_trades'] is num)
            ? (json['total_trades'] as num).toInt()
            : unified.length;

    return ActiveTradesData(
      totalScans: json['total_scans'] ?? 0,
      totalTrades: totalTrades,
      dateFilter: DateFilter.fromJson(json['date_filter'] ?? {}),
      analysis: unified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_scans': totalScans,
      'total_trades': totalTrades,
      'date_filter': dateFilter.toJson(),
      'analysis': analysis.map((trade) => trade.toJson()).toList(),
    };
  }
}

class DateFilter {
  final String startDate;
  final String endDate;

  DateFilter({required this.startDate, required this.endDate});

  factory DateFilter.fromJson(Map<String, dynamic> json) {
    return DateFilter(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'start_date': startDate, 'end_date': endDate};
  }
}

class ActiveTrade {
  final String symbol;
  final String recommendation;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final int positionSize;
  final double riskRewardRatio;
  final String entryDate;
  final String exitDate;
  final String strategy;
  final int scanId;
  final String scanCreatedAt;
  final String analyzedAt;

  ActiveTrade({
    required this.symbol,
    required this.recommendation,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.positionSize,
    required this.riskRewardRatio,
    required this.entryDate,
    required this.exitDate,
    required this.strategy,
    required this.scanId,
    required this.scanCreatedAt,
    required this.analyzedAt,
  });

  factory ActiveTrade.fromJson(Map<String, dynamic> json) {
    return ActiveTrade(
      symbol: json['symbol'] ?? '',
      recommendation: json['recommendation'] ?? '',
      entryPrice: _parseDouble(json['entry_price']),
      stopLoss: _parseDouble(json['stop_loss']),
      takeProfit: _parseDouble(json['take_profit']),
      positionSize: json['position_size'] ?? 0,
      riskRewardRatio: _parseDouble(json['risk_reward_ratio']),
      entryDate: json['entry_date'] ?? '',
      exitDate: json['exit_date'] ?? '',
      strategy: json['strategy'] ?? '',
      scanId: json['scan_id'] ?? 0,
      scanCreatedAt: json['scan_created_at'] ?? '',
      analyzedAt: json['analyzed_at'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value == '-' || value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'recommendation': recommendation,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'position_size': positionSize,
      'risk_reward_ratio': riskRewardRatio,
      'entry_date': entryDate,
      'exit_date': exitDate,
      'strategy': strategy,
      'scan_id': scanId,
      'scan_created_at': scanCreatedAt,
      'analyzed_at': analyzedAt,
    };
  }
}
