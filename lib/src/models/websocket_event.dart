class WebSocketEvent {
  final String event;
  final String? id;
  final String? message;
  final String? timestamp;
  final int? progress;

  WebSocketEvent({
    required this.event,
    this.id,
    this.message,
    this.timestamp,
    this.progress,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      event: json['event'] ?? '',
      id: json['id']?.toString(),
      message: json['message'],
      timestamp: json['timestamp'],
      progress: json['progress'] is int ? json['progress'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (progress != null) 'progress': progress,
    };
  }

  bool get isScanCompleted => event == 'scan_completed';
  bool get isAnalysisCompleted => event == 'analysis_completed';
  bool get isFullAnalysisCompleted => event == 'full_analysis_completed';
  bool get isLimitedAnalysisCompleted => event == 'limited_analysis_completed';
  bool get isScanProgress => event == 'scan_progress';
  bool get isAnalysisProgress => event == 'analysis_progress';
  bool get isFullAnalysisProgress => event == 'full_analysis_progress';
  bool get isLimitedAnalysisProgress => event == 'limited_analysis_progress';
  bool get isConnected => event == 'connected';
}

enum WebSocketConnectionStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}
