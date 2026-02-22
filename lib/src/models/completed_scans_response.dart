class CompletedScansResponse {
  final bool success;
  final int status;
  final String message;
  final List<CompletedScanData> data;

  CompletedScansResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CompletedScansResponse.fromJson(Map<String, dynamic> json) {
    return CompletedScansResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    CompletedScanData.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class CompletedScanData {
  final int id;
  final String createdAt;

  CompletedScanData({required this.id, required this.createdAt});

  factory CompletedScanData.fromJson(Map<String, dynamic> json) {
    return CompletedScanData(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  DateTime get createdDateTime {
    try {
      return DateTime.parse(createdAt);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
