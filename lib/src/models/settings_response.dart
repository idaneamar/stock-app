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

  SettingsData({
    required this.portfolioSize,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      portfolioSize: (json['portfolio_size'] ?? 350000).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio_size': portfolioSize,
    };
  }
}
