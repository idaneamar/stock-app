class SettingsResponse {
  final bool success;
  final int status;
  final String message;
  final SettingsData data;

  SettingsResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: SettingsData.fromJson(json['data'] ?? {}),
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

class SettingsData {
  final double portfolioSize;
  final bool strictRules;
  final double? adxMin;
  final bool volumeSpikeRequired;
  final bool useIntraday;
  final double dailyLossLimitPct;

  SettingsData({
    required this.portfolioSize,
    this.strictRules = true,
    this.adxMin,
    this.volumeSpikeRequired = false,
    this.useIntraday = false,
    this.dailyLossLimitPct = 0.02,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      portfolioSize: (json['portfolio_size'] ?? 350000).toDouble(),
      strictRules: json['strict_rules'] ?? true,
      adxMin:
          json['adx_min'] != null ? (json['adx_min'] as num).toDouble() : null,
      volumeSpikeRequired: json['volume_spike_required'] ?? false,
      useIntraday: json['use_intraday'] ?? false,
      dailyLossLimitPct: (json['daily_loss_limit_pct'] ?? 0.02).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio_size': portfolioSize,
      'strict_rules': strictRules,
      'adx_min': adxMin,
      'volume_spike_required': volumeSpikeRequired,
      'use_intraday': useIntraday,
      'daily_loss_limit_pct': dailyLossLimitPct,
    };
  }
}
