import 'package:dio/dio.dart';
import 'package:runvibe_mobile/core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  Future<void> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'auth/login',
      data: {'email': email.trim(), 'password': password},
    );
    await _saveResponseToken(response.data);
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'auth/register',
      data: {'name': name.trim(), 'email': email.trim(), 'password': password},
    );
    await _saveResponseToken(response.data);
  }

  Future<void> _saveResponseToken(Map<String, dynamic>? data) async {
    final token = data?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('A API não retornou um token válido');
    }
    await _tokens.save(token);
  }
}
