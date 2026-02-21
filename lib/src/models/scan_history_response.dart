class ScanHistoryResponse {
  final bool success;
  final int status;
  final String message;
  final List<ScanHistoryData> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  ScanHistoryResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ScanHistoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle both old format (direct array) and new paginated format
    final responseData = json['data'];
    List<ScanHistoryData> items;
    int total = 0;
    int page = 1;
    int pageSize = 10;
    int totalPages = 1;
    bool hasNext = false;
    bool hasPrevious = false;

    if (responseData is Map<String, dynamic>) {
      // New paginated format
      items = (responseData['items'] as List<dynamic>?)
          ?.map((item) => ScanHistoryData.fromJson(item))
          .toList() ?? [];
      total = responseData['total'] ?? items.length;
      page = responseData['page'] ?? 1;
      pageSize = responseData['page_size'] ?? 10;
      totalPages = responseData['total_pages'] ?? 1;
      hasNext = responseData['has_next'] ?? false;
      hasPrevious = responseData['has_previous'] ?? false;
    } else if (responseData is List<dynamic>) {
      // Old format (direct array)
      items = responseData
          .map((item) => ScanHistoryData.fromJson(item))
          .toList();
      total = items.length;
    } else {
      items = [];
    }

    return ScanHistoryResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: items,
      total: total,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'message': message,
      'data': {
        'items': data.map((item) => item.toJson()).toList(),
        'total': total,
        'page': page,
        'page_size': pageSize,
        'total_pages': totalPages,
        'has_next': hasNext,
        'has_previous': hasPrevious,
      },
    };
  }
}

class ScanHistoryData {
  final int id;
  final String status;
  final int scanProgress;
  final String analysisStatus;
  final int analysisProgress;
  final String fullAnalysisStatus;
  final int fullAnalysisProgress;
  final String limitedAnalysisStatus;
  final int limitedAnalysisProgress;
  final ScanHistoryCriteria criteria;
  final List<StockSymbol> stockSymbols;
  final int totalFound;
  final String? errorMessage;
  final String createdAt;
  final String? completedAt;
  final String? analyzedAt;
  final String? fullAnalyzedAt;
  final String? limitedAnalyzedAt;

  ScanHistoryData({
    required this.id,
    required this.status,
    required this.scanProgress,
    required this.analysisStatus,
    required this.analysisProgress,
    required this.fullAnalysisStatus,
    required this.fullAnalysisProgress,
    required this.limitedAnalysisStatus,
    required this.limitedAnalysisProgress,
    required this.criteria,
    required this.stockSymbols,
    required this.totalFound,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.analyzedAt,
    this.fullAnalyzedAt,
    this.limitedAnalyzedAt,
  });

  factory ScanHistoryData.fromJson(Map<String, dynamic> json) {
    final analysisStatus =
        (json['analysis_status'] ?? '').toString().isNotEmpty
            ? (json['analysis_status'] ?? '').toString()
            : (json['full_analysis_status'] ?? json['limited_analysis_status'] ?? '')
                .toString();

    final analysisProgress =
        (json['analysis_progress'] is int)
            ? (json['analysis_progress'] as int)
            : _maxInt(json['full_analysis_progress'], json['limited_analysis_progress']);

    final analyzedAt =
        (json['analyzed_at'] ??
                json['analysis_completed_at'] ??
                json['full_analyzed_at'] ??
                json['limited_analyzed_at'])
            ?.toString();

    return ScanHistoryData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      scanProgress: json['scan_progress'] ?? 0,
      analysisStatus: analysisStatus,
      analysisProgress: analysisProgress,
      fullAnalysisStatus: (json['full_analysis_status'] ?? analysisStatus).toString(),
      fullAnalysisProgress:
          (json['full_analysis_progress'] is int)
              ? json['full_analysis_progress']
              : analysisProgress,
      limitedAnalysisStatus:
          (json['limited_analysis_status'] ?? analysisStatus).toString(),
      limitedAnalysisProgress:
          (json['limited_analysis_progress'] is int)
              ? json['limited_analysis_progress']
              : analysisProgress,
      criteria: ScanHistoryCriteria.fromJson(json['criteria'] ?? {}),
      stockSymbols: (json['stock_symbols'] as List<dynamic>? ?? [])
          .map((item) => StockSymbol.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalFound: json['total_found'] ?? 0,
      errorMessage: json['error_message'],
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
      analyzedAt: analyzedAt,
      fullAnalyzedAt: (json['full_analyzed_at'] ?? analyzedAt)?.toString(),
      limitedAnalyzedAt: (json['limited_analyzed_at'] ?? analyzedAt)?.toString(),
    );
  }

  static int _maxInt(dynamic a, dynamic b) {
    final ai = a is int ? a : int.tryParse(a?.toString() ?? '');
    final bi = b is int ? b : int.tryParse(b?.toString() ?? '');
    return [ai ?? 0, bi ?? 0].reduce((x, y) => x > y ? x : y);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'scan_progress': scanProgress,
      'analysis_status': analysisStatus,
      'analysis_progress': analysisProgress,
      'full_analysis_status': fullAnalysisStatus,
      'full_analysis_progress': fullAnalysisProgress,
      'limited_analysis_status': limitedAnalysisStatus,
      'limited_analysis_progress': limitedAnalysisProgress,
      'criteria': criteria.toJson(),
      'stock_symbols': stockSymbols.map((item) => item.toJson()).toList(),
      'total_found': totalFound,
      'error_message': errorMessage,
      'created_at': createdAt,
      'completed_at': completedAt,
      'analyzed_at': analyzedAt,
      'full_analyzed_at': fullAnalyzedAt,
      'limited_analyzed_at': limitedAnalyzedAt,
    };
  }
}

class ScanHistoryCriteria {
  final double minMarketCap;
  final double maxMarketCap;
  final double minAvgVolume;
  final double minAvgTransactionValue;
  final double minVolatility;
  final double minPrice;
  final int topNStocks;

  ScanHistoryCriteria({
    required this.minMarketCap,
    required this.maxMarketCap,
    required this.minAvgVolume,
    required this.minAvgTransactionValue,
    required this.minVolatility,
    required this.minPrice,
    required this.topNStocks,
  });

  factory ScanHistoryCriteria.fromJson(Map<String, dynamic> json) {
    return ScanHistoryCriteria(
      minMarketCap: (json['min_market_cap'] ?? 0).toDouble(),
      maxMarketCap: (json['max_market_cap'] ?? 0).toDouble(),
      minAvgVolume: (json['min_avg_volume'] ?? 0).toDouble(),
      minAvgTransactionValue:
          (json['min_avg_transaction_value'] ?? 0).toDouble(),
      minVolatility: (json['min_volatility'] ?? 0).toDouble(),
      minPrice: (json['min_price'] ?? 0).toDouble(),
      topNStocks: (json['top_n_stocks'] ?? 0).round(),
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

class StockSymbol {
  final String ticker;
  final String companyName;
  final double marketCap;
  final double price;
  final double volatility;
  final double avgVolume;
  final double avgTransactionValue;

  StockSymbol({
    required this.ticker,
    required this.companyName,
    required this.marketCap,
    required this.price,
    required this.volatility,
    required this.avgVolume,
    required this.avgTransactionValue,
  });

  factory StockSymbol.fromJson(Map<String, dynamic> json) {
    return StockSymbol(
      ticker: json['ticker'] ?? '',
      companyName: json['company_name'] ?? '',
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      volatility: (json['volatility'] ?? 0).toDouble(),
      avgVolume: (json['avg_volume'] ?? 0).toDouble(),
      avgTransactionValue: (json['avg_transaction_value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'company_name': companyName,
      'market_cap': marketCap,
      'price': price,
      'volatility': volatility,
      'avg_volume': avgVolume,
      'avg_transaction_value': avgTransactionValue,
    };
  }
}
