class DateRangeResponse {
  final bool success;
  final int status;
  final String message;
  final DateRangeData data;

  DateRangeResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory DateRangeResponse.fromJson(Map<String, dynamic> json) {
    return DateRangeResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: DateRangeData.fromJson(json['data'] ?? {}),
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

class DateRangeData {
  final String firstScanDate;
  final String lastScanDate;

  DateRangeData({
    required this.firstScanDate,
    required this.lastScanDate,
  });

  factory DateRangeData.fromJson(Map<String, dynamic> json) {
    return DateRangeData(
      firstScanDate: json['first_scan_date'] ?? '',
      lastScanDate: json['last_scan_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_scan_date': firstScanDate,
      'last_scan_date': lastScanDate,
    };
  }

  DateTime get firstScanDateTime {
    return DateTime.parse(firstScanDate);
  }

  DateTime get lastScanDateTime {
    return DateTime.parse(lastScanDate);
  }
}