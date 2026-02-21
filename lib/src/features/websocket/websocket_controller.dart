import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:stock_app/src/models/websocket_event.dart';
import 'package:stock_app/src/utils/services/websocket_service.dart';

class WebSocketController extends GetxController {
  final WebSocketService _webSocketService = WebSocketService();

  final RxBool _isConnected = false.obs;
  final RxBool _isConnecting = false.obs;
  final RxString _connectionStatus = 'Disconnected'.obs;
  final RxList<WebSocketEvent> _recentEvents = <WebSocketEvent>[].obs;

  StreamSubscription<WebSocketEvent>? _eventSubscription;
  StreamSubscription<WebSocketConnectionStatus>? _statusSubscription;

  bool get isConnected => _isConnected.value;
  bool get isConnecting => _isConnecting.value;
  String get connectionStatus => _connectionStatus.value;
  List<WebSocketEvent> get recentEvents => _recentEvents;

  final Map<String, List<Function(WebSocketEvent)>> _eventHandlers = {};

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _eventSubscription = _webSocketService.eventStream.listen(
      _handleWebSocketEvent,
      onError: (error) {
        log('WebSocket event stream error: $error');
      },
    );

    _statusSubscription = _webSocketService.statusStream.listen(
      _handleConnectionStatus,
      onError: (error) {
        log('WebSocket status stream error: $error');
      },
    );
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    log('Handling WebSocket event: ${event.event}');

    final currentEvents = <WebSocketEvent>[event, ..._recentEvents];
    _recentEvents.assignAll(currentEvents.take(50).toList());

    final handlers = _eventHandlers[event.event];
    if (handlers != null) {
      for (final handler in handlers) {
        try {
          handler(event);
        } catch (e) {
          log('Error executing event handler for ${event.event}: $e');
        }
      }
    }

    if (event.isScanCompleted) {
      _handleScanCompleted(event);
    } else if (event.isFullAnalysisCompleted) {
      _handleFullAnalysisCompleted(event);
    } else if (event.isLimitedAnalysisCompleted) {
      _handleLimitedAnalysisCompleted(event);
    } else if (event.isScanProgress) {
      _handleScanProgress(event);
    } else if (event.isFullAnalysisProgress) {
      _handleFullAnalysisProgress(event);
    } else if (event.isLimitedAnalysisProgress) {
      _handleLimitedAnalysisProgress(event);
    }
  }

  void _handleConnectionStatus(WebSocketConnectionStatus status) {
    switch (status) {
      case WebSocketConnectionStatus.connecting:
        _isConnecting.value = true;
        _isConnected.value = false;
        _connectionStatus.value = 'Connecting...';
        break;
      case WebSocketConnectionStatus.connected:
        _isConnecting.value = false;
        _isConnected.value = true;
        _connectionStatus.value = 'Connected';
        break;
      case WebSocketConnectionStatus.disconnected:
        _isConnecting.value = false;
        _isConnected.value = false;
        _connectionStatus.value = 'Disconnected';
        break;
      case WebSocketConnectionStatus.reconnecting:
        _isConnecting.value = true;
        _isConnected.value = false;
        _connectionStatus.value = 'Reconnecting...';
        break;
      case WebSocketConnectionStatus.error:
        _isConnecting.value = false;
        _isConnected.value = false;
        _connectionStatus.value = 'Connection Error';
        break;
    }

    log('WebSocket connection status: ${_connectionStatus.value}');
  }

  void _handleScanCompleted(WebSocketEvent event) {
    if (event.id != null) {
      log('Scan completed for ID: ${event.id}');
    }
  }

  void _handleFullAnalysisCompleted(WebSocketEvent event) {
    if (event.id != null) {
      log('Full analysis completed for ID: ${event.id}');
    }
  }

  void _handleLimitedAnalysisCompleted(WebSocketEvent event) {
    if (event.id != null) {
      log('Limited analysis completed for ID: ${event.id}');
    }
  }

  void _handleScanProgress(WebSocketEvent event) {
    if (event.id != null && event.progress != null) {
      log('Scan progress for ID: ${event.id}, progress: ${event.progress}%');
    }
  }

  void _handleFullAnalysisProgress(WebSocketEvent event) {
    if (event.id != null && event.progress != null) {
      log(
        'Full analysis progress for ID: ${event.id}, progress: ${event.progress}%',
      );
    }
  }

  void _handleLimitedAnalysisProgress(WebSocketEvent event) {
    if (event.id != null && event.progress != null) {
      log(
        'Limited analysis progress for ID: ${event.id}, progress: ${event.progress}%',
      );
    }
  }

  void addEventListener(String eventType, Function(WebSocketEvent) handler) {
    if (_eventHandlers[eventType] == null) {
      _eventHandlers[eventType] = [];
    }
    _eventHandlers[eventType]!.add(handler);
  }

  void removeEventListener(String eventType, Function(WebSocketEvent) handler) {
    _eventHandlers[eventType]?.remove(handler);
  }

  Future<void> connect() async {
    if (!_isConnected.value && !_isConnecting.value) {
      await _webSocketService.connect();
    }
  }

  void disconnect() {
    _webSocketService.disconnect();
  }

  void clearRecentEvents() {
    _recentEvents.clear();
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    _statusSubscription?.cancel();
    _webSocketService.dispose();
    super.onClose();
  }
}
