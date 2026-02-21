class TradeResponse {
  final bool success;
  final int status;
  final String message;
  final TradeData data;

  TradeResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory TradeResponse.fromJson(Map<String, dynamic> json) {
    return TradeResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: TradeData.fromJson(json['data'] ?? {}),
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

class TradeData {
  final int scanId;
  final String status;
  final int progress;
  final String analyzedAt;
  final double? portfolioSize;
  final List<Trade> analysis;

  TradeData({
    required this.scanId,
    required this.status,
    required this.progress,
    required this.analyzedAt,
    this.portfolioSize,
    required this.analysis,
  });

  factory TradeData.fromJson(Map<String, dynamic> json) {
    List<Trade> parseTrades(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Trade.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (value is Map) {
        final items = value['items'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((e) => Trade.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    }

    // New unified format: `data.analysis` is a single list.
    // Backward compatibility: legacy `analysis.results`/`analysis.suggestions` are merged.
    final rawAnalysis = json['analysis'];
    List<Trade> unified;
    if (rawAnalysis is List) {
      unified = parseTrades(rawAnalysis);
    } else if (rawAnalysis is Map) {
      unified = <Trade>[
        ...parseTrades(rawAnalysis['results']),
        ...parseTrades(rawAnalysis['suggestions']),
      ];
      if (unified.isEmpty) {
        unified = parseTrades(rawAnalysis);
      }
    } else {
      unified = parseTrades(json['trades']);
    }

    return TradeData(
      scanId: json['scan_id'] ?? 0,
      status: json['status'] ?? '',
      progress: (json['progress'] ?? json['analysis_progress'] ?? 0) as int,
      analyzedAt: (json['analyzed_at'] ?? '').toString(),
      portfolioSize:
          json['portfolio_size'] == null
              ? null
              : (json['portfolio_size'] as num).toDouble(),
      analysis: unified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'status': status,
      'progress': progress,
      'analyzed_at': analyzedAt,
      if (portfolioSize != null) 'portfolio_size': portfolioSize,
      'analysis': analysis.map((item) => item.toJson()).toList(),
    };
  }
}

class Trade {
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
  final String score;

  Trade({
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
    required this.score,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      symbol: json['symbol'] ?? '',
      recommendation: json['recommendation'] ?? '',
      entryPrice: (json['entry_price'] ?? 0).toDouble(),
      stopLoss: (json['stop_loss'] ?? 0).toDouble(),
      takeProfit: (json['take_profit'] ?? 0).toDouble(),
      positionSize: json['position_size'] ?? 0,
      riskRewardRatio: (json['risk_reward_ratio'] ?? 0).toDouble(),
      entryDate: json['entry_date'] ?? '',
      exitDate: json['exit_date'] ?? '',
      strategy: json['strategy'] ?? '',
      score: json['score'] == null ? 'Not Available' : json['score'].toString(),
    );
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
      'score': score,
    };
  }
}
