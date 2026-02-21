class StrategiesListResponse {
  final bool success;
  final int status;
  final String message;
  final StrategiesListData data;

  StrategiesListResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory StrategiesListResponse.fromJson(Map<String, dynamic> json) {
    return StrategiesListResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: StrategiesListData.fromJson(json['data'] ?? const {}),
    );
  }
}

class StrategiesListData {
  final List<StrategyItem> items;
  final int total;

  StrategiesListData({required this.items, required this.total});

  factory StrategiesListData.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items =
        (itemsJson is List)
            ? itemsJson
                .whereType<Map>()
                .map((e) => StrategyItem.fromJson(e.cast<String, dynamic>()))
                .toList()
            : <StrategyItem>[];

    return StrategiesListData(
      items: items,
      total: (json['total'] ?? items.length) as int,
    );
  }
}

class StrategyItem {
  final int id;
  final String name;
  final bool enabled;
  final Map<String, dynamic> config;
  final bool ignoreVix;

  StrategyItem({
    required this.id,
    required this.name,
    required this.enabled,
    required this.config,
    this.ignoreVix = false,
  });

  factory StrategyItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id =
        rawId is int
            ? rawId
            : rawId is num
            ? rawId.toInt()
            : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final configJson = json['config'];
    final config = configJson is Map<String, dynamic> ? configJson : <String, dynamic>{};
    final ignoreVix = json['ignore_vix'] == true || (config['ignore_vix'] == true);
    return StrategyItem(
      id: id,
      name: (json['name'] ?? '').toString(),
      enabled: json['enabled'] == true,
      config: config,
      ignoreVix: ignoreVix,
    );
  }

  /// Serializes for client use. Does not include ignore_vix (VIX is global in Settings).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'enabled': enabled,
      'config': config,
    };
  }
}

class StrategyResponse {
  final bool success;
  final int status;
  final String message;
  final StrategyItem data;

  StrategyResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory StrategyResponse.fromJson(Map<String, dynamic> json) {
    return StrategyResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: StrategyItem.fromJson(json['data'] ?? const {}),
    );
  }
}
