import 'package:dio/dio.dart';
import 'package:runvibe_mobile/core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  Future<void> login(String email, String password) async {
    await _wakeServer();
    final response = await _postWithRetry('auth/login', {
      'email': email.trim(),
      'password': password,
    });
    await _saveResponseToken(response.data);
  }

  Future<void> register(String name, String email, String password) async {
    await _wakeServer();
    final response = await _postWithRetry('auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
    await _saveResponseToken(response.data);
  }

  Future<void> _wakeServer() async {
    try {
      await _dio.getUri<void>(
        Uri.parse('https://runvibe-api.onrender.com/actuator/health'),
      );
    } on DioException catch (error) {
      if (!_isTemporaryNetworkFailure(error)) rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> _postWithRetry(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _dio.post<Map<String, dynamic>>(path, data: data);
    } on DioException catch (error) {
      if (!_isTemporaryNetworkFailure(error)) rethrow;
      await Future<void>.delayed(const Duration(seconds: 2));
      return _dio.post<Map<String, dynamic>>(path, data: data);
    }
  }

  bool _isTemporaryNetworkFailure(DioException error) =>
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;

  Future<void> _saveResponseToken(Map<String, dynamic>? data) async {
    final token = data?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('A API não retornou um token válido');
    }
    await _tokens.save(token);
  }
}
