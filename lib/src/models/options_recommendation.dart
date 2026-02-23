/// Iron Condor recommendation as returned by the /options/recommendations endpoint.
class OptionsRecommendation {
  final String ticker;
  final String? runDate;
  final String? exp;
  final int? dte;
  final double? shortPut;
  final double? longPut;
  final double? shortCall;
  final double? longCall;
  final double? width;
  final double? netCredit;
  final double? maxLossPerShare;
  final double? popEst;
  final String? popMethod;
  final double? spot;
  final double? ivEst;
  final double? spDelta;
  final double? scDelta;
  final double? score;
  final int? contracts;
  final double? maxRiskUsd;
  final double? maxProfitUsd;

  const OptionsRecommendation({
    required this.ticker,
    this.runDate,
    this.exp,
    this.dte,
    this.shortPut,
    this.longPut,
    this.shortCall,
    this.longCall,
    this.width,
    this.netCredit,
    this.maxLossPerShare,
    this.popEst,
    this.popMethod,
    this.spot,
    this.ivEst,
    this.spDelta,
    this.scDelta,
    this.score,
    this.contracts,
    this.maxRiskUsd,
    this.maxProfitUsd,
  });

  factory OptionsRecommendation.fromJson(Map<String, dynamic> json) {
    return OptionsRecommendation(
      ticker: (json['ticker'] as String?) ?? '',
      runDate: json['run_date'] as String?,
      exp: json['exp'] as String?,
      dte: _toInt(json['dte']),
      shortPut: _toDouble(json['short_put']),
      longPut: _toDouble(json['long_put']),
      shortCall: _toDouble(json['short_call']),
      longCall: _toDouble(json['long_call']),
      width: _toDouble(json['width']),
      netCredit: _toDouble(json['net_credit']),
      maxLossPerShare: _toDouble(json['max_loss_per_share']),
      popEst: _toDouble(json['pop_est']),
      popMethod: json['pop_method'] as String?,
      spot: _toDouble(json['spot']),
      ivEst: _toDouble(json['iv_est']),
      spDelta: _toDouble(json['sp_delta']),
      scDelta: _toDouble(json['sc_delta']),
      score: _toDouble(json['score']),
      contracts: _toInt(json['contracts']),
      maxRiskUsd: _toDouble(json['max_risk_usd']),
      maxProfitUsd: _toDouble(json['max_profit_usd']),
    );
  }

  Map<String, dynamic> toJson() => {
    'ticker': ticker,
    'run_date': runDate,
    'exp': exp,
    'dte': dte,
    'short_put': shortPut,
    'long_put': longPut,
    'short_call': shortCall,
    'long_call': longCall,
    'width': width,
    'net_credit': netCredit,
    'max_loss_per_share': maxLossPerShare,
    'pop_est': popEst,
    'pop_method': popMethod,
    'spot': spot,
    'iv_est': ivEst,
    'sp_delta': spDelta,
    'sc_delta': scDelta,
    'score': score,
    'contracts': contracts,
    'max_risk_usd': maxRiskUsd,
    'max_profit_usd': maxProfitUsd,
  };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

/// Response wrapper for the /options/recommendations endpoint.
class OptionsRecsResponse {
  final String? date;
  final List<OptionsRecommendation> recommendations;
  final int count;

  const OptionsRecsResponse({
    this.date,
    required this.recommendations,
    required this.count,
  });

  factory OptionsRecsResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['recommendations'] as List?) ?? [];
    return OptionsRecsResponse(
      date: json['date'] as String?,
      recommendations:
          rawList
              .map(
                (e) =>
                    OptionsRecommendation.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      count: (json['count'] as int?) ?? rawList.length,
    );
  }
}

/// System status response from /options/status.
class OptionsStatus {
  final int symbolCount;
  final String? latestRecommendationDate;
  final List<String> availableRecommendationDates;
  final String? nextFetchSymbols;
  final String? nextPrefetch;
  final List<Map<String, dynamic>> scheduledJobs;

  const OptionsStatus({
    required this.symbolCount,
    this.latestRecommendationDate,
    required this.availableRecommendationDates,
    this.nextFetchSymbols,
    this.nextPrefetch,
    required this.scheduledJobs,
  });

  factory OptionsStatus.fromJson(Map<String, dynamic> json) {
    return OptionsStatus(
      symbolCount: (json['symbol_count'] as int?) ?? 0,
      latestRecommendationDate: json['latest_recommendation_date'] as String?,
      availableRecommendationDates:
          ((json['available_recommendation_dates'] as List?) ?? [])
              .map((e) => e.toString())
              .toList(),
      nextFetchSymbols: json['next_fetch_symbols'] as String?,
      nextPrefetch: json['next_prefetch'] as String?,
      scheduledJobs:
          ((json['scheduled_jobs'] as List?) ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
    );
  }
}
