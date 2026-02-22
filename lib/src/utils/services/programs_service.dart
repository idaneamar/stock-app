import 'package:dio/dio.dart';
import 'package:stock_app/src/utils/services/api_client.dart';

class ProgramsService {
  final ApiClient _client = ApiClient();

  Future<Response> listPrograms() async {
    try {
      return await _client.dio.get('programs/');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> createProgram(Map<String, dynamic> payload) async {
    try {
      return await _client.dio.post('programs/', data: payload);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> applyProgram(String programId) async {
    try {
      return await _client.dio.post(
        'programs/apply',
        data: {'program_id': programId, 'persist_as_active': true},
      );
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> revertToBaseline() async {
    try {
      return await _client.dio.post('programs/revert-baseline', data: '');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Response> deleteProgram(String programId) async {
    try {
      return await _client.dio.delete('programs/$programId');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }
}
