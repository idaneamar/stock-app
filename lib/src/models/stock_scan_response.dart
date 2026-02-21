class StockScanResponse {
  final bool success;
  final int status;
  final String message;
  final StockScanData data;

  StockScanResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory StockScanResponse.fromJson(Map<String, dynamic> json) {
    return StockScanResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: StockScanData.fromJson(json['data'] ?? {}),
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

class StockScanData {
  final int scanId;
  final String status;
  final String message;
  final CriteriaUsed criteriaUsed;
  final String scanTimestamp;

  StockScanData({
    required this.scanId,
    required this.status,
    required this.message,
    required this.criteriaUsed,
    required this.scanTimestamp,
  });

  factory StockScanData.fromJson(Map<String, dynamic> json) {
    return StockScanData(
      scanId: json['scan_id'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      criteriaUsed: CriteriaUsed.fromJson(json['criteria_used'] ?? {}),
      scanTimestamp: json['scan_timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'status': status,
      'message': message,
      'criteria_used': criteriaUsed.toJson(),
      'scan_timestamp': scanTimestamp,
    };
  }
}

class CriteriaUsed {
  final double minMarketCap;
  final double maxMarketCap;
  final double minAvgVolume;
  final double minAvgTransactionValue;
  final double minVolatility;
  final double minPrice;
  final int topNStocks;

  CriteriaUsed({
    required this.minMarketCap,
    required this.maxMarketCap,
    required this.minAvgVolume,
    required this.minAvgTransactionValue,
    required this.minVolatility,
    required this.minPrice,
    required this.topNStocks,
  });

  factory CriteriaUsed.fromJson(Map<String, dynamic> json) {
    return CriteriaUsed(
      minMarketCap: (json['min_market_cap'] ?? 0).toDouble(),
      maxMarketCap: (json['max_market_cap'] ?? 0).toDouble(),
      minAvgVolume: (json['min_avg_volume'] ?? 0).toDouble(),
      minAvgTransactionValue: (json['min_avg_transaction_value'] ?? 0).toDouble(),
      minVolatility: (json['min_volatility'] ?? 0).toDouble(),
      minPrice: (json['min_price'] ?? 0).toDouble(),
      topNStocks: (json['top_n_stocks'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_market_cap': minMarketCap,
      'max_market_cap': maxMarketCap,
      'min_avg_volume': minAvgVolume,
      'min_avg_transaction_value': minAvgTransactionValue,
      'min_volatility': minVolatility,
      'min_price': minPrice,
      'top_n_stocks': topNStocks,
    };
  }
}