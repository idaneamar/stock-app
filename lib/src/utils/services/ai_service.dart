import 'package:dio/dio.dart';
import 'package:stock_app/src/utils/services/api_client.dart';

class AiService {
  final ApiClient _client = ApiClient();

  Future<Response> chat({
    required int scanId,
    String? scanDate,
    double? portfolioSize,
    required List<Map<String, dynamic>> trades,
    required List<Map<String, String>> messages,
  }) async {
    try {
      return await _client.dio.post(
        'ai/chat',
        data: {
          'scan_id': scanId,
          if (scanDate != null) 'scan_date': scanDate,
          if (portfolioSize != null) 'portfolio_size': portfolioSize,
          'trades': trades,
          'messages': messages,
        },
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }
}
