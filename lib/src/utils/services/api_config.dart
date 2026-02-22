import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _prodHttpBaseUrl =
      'https://stock-api-1-jhsa.onrender.com/';
  static const String _localHttpBaseUrl = 'http://localhost:8000/';

  static String get httpBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return _normalizeHttpBaseUrl(override);
    return _normalizeHttpBaseUrl(
      kReleaseMode ? _prodHttpBaseUrl : _localHttpBaseUrl,
    );
  }

  static String get webSocketBaseUrl {
    const override = String.fromEnvironment('WS_BASE_URL');
    if (override.isNotEmpty) return _normalizeWebSocketBaseUrl(override);
    return _normalizeWebSocketBaseUrl(_deriveWebSocketBaseUrl(httpBaseUrl));
  }

  static String _normalizeHttpBaseUrl(String url) {
    var normalized = url.trim();
    if (!normalized.endsWith('/')) normalized = '$normalized/';
    return normalized;
  }

  static String _normalizeWebSocketBaseUrl(String url) {
    var normalized = url.trim();
    if (normalized.endsWith('/'))
      normalized = normalized.substring(0, normalized.length - 1);
    return normalized;
  }

  static String _deriveWebSocketBaseUrl(String httpBaseUrl) {
    final uri = Uri.parse(httpBaseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: scheme, path: '').toString();
  }
}
