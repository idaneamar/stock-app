import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stock_app/src/models/websocket_event.dart';
import 'package:stock_app/src/utils/services/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final String _baseUrl = ApiConfig.webSocketBaseUrl;
  final String _endpoint = '/listen_events';

  final StreamController<WebSocketEvent> _eventController =
      StreamController<WebSocketEvent>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  Stream<WebSocketConnectionStatus> get statusStream =>
      _statusController.stream;

  WebSocketConnectionStatus _currentStatus =
      WebSocketConnectionStatus.disconnected;
  WebSocketConnectionStatus get currentStatus => _currentStatus;

  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  Future<void> connect() async {
    if (_isConnecting ||
        _currentStatus == WebSocketConnectionStatus.connected) {
      return;
    }

    _isConnecting = true;
    _shouldReconnect = true;
    _updateStatus(WebSocketConnectionStatus.connecting);

    try {
      await _createConnection();
    } catch (e) {
      log('WebSocket connection failed: $e');
      _handleConnectionError();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _createConnection() async {
    final uri = Uri.parse('$_baseUrl$_endpoint');

    try {
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _updateStatus(WebSocketConnectionStatus.connected);
      _startHeartbeat();

      log('WebSocket connected successfully to: $uri');
    } catch (e) {
      log('Error creating WebSocket connection: $e');
      rethrow;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      String messageString = message.toString();

      if (messageString.startsWith('Message received: ')) {
        messageString = messageString.substring('Message received: '.length);
      }

      if (messageString.contains('"type":"ping"')) {
        log('Received heartbeat ping response');
        return;
      }

      final data = json.decode(messageString);
      final event = WebSocketEvent.fromJson(data);

      log('WebSocket received event: ${event.event}');

      if (event.isConnected) {
        log('WebSocket connection confirmed: ${event.message}');
      }

      _eventController.add(event);
    } catch (e) {
      log('Error parsing WebSocket message: $e');
      log('Raw message: $message');
    }
  }

  void _handleError(error) {
    log('WebSocket error: $error');
    _updateStatus(WebSocketConnectionStatus.error);
    _handleConnectionError();
  }

  void _handleDisconnect() {
    log('WebSocket disconnected');
    _cleanup();
    _updateStatus(WebSocketConnectionStatus.disconnected);

    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionError() {
    _cleanup();

    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      _updateStatus(WebSocketConnectionStatus.error);
      log('WebSocket max reconnection attempts reached');
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;

    _reconnectAttempts++;
    _updateStatus(WebSocketConnectionStatus.reconnecting);

    log(
      'WebSocket scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_currentStatus == WebSocketConnectionStatus.connected) {
        try {
          _channel?.sink.add(json.encode({'type': 'ping'}));
        } catch (e) {
          log('Heartbeat failed: $e');
          _handleConnectionError();
        }
      }
    });
  }

  void _updateStatus(WebSocketConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
      log('WebSocket status updated: $status');
    }
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;

    _channel?.sink.close();
    _channel = null;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void disconnect() {
    log('WebSocket disconnecting manually');
    _shouldReconnect = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _cleanup();
    _updateStatus(WebSocketConnectionStatus.disconnected);
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _cleanup();
    _eventController.close();
    _statusController.close();
  }

  bool get isConnected => _currentStatus == WebSocketConnectionStatus.connected;
  bool get isConnecting =>
      _currentStatus == WebSocketConnectionStatus.connecting;
  bool get isReconnecting =>
      _currentStatus == WebSocketConnectionStatus.reconnecting;
}
