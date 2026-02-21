import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:stock_app/src/utils/services/api_config.dart';

/// Base API client with Dio configuration
/// All domain-specific services should use this client
class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.httpBaseUrl,
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: kIsWeb ? null : const Duration(minutes: 2),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );
    _setupInterceptors();
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('Request: ${options.method} ${options.uri}');
          log('Headers: ${options.headers}');
          log('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.statusCode}');
          log('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          log('Error: ${error.message}');
          log('Error Type: ${error.type}');
          handler.next(error);
        },
      ),
    );
  }

  /// Excel response options
  Options get excelOptions => Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
      );

  /// Handles API errors and throws formatted exceptions
  Exception handleError(DioException e) {
    final message = e.response?.data ?? e.message;
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      return Exception('API Error: Status $statusCode - $message');
    }
    return Exception('API Error: $message');
  }
}
