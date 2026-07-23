import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:runvibe_mobile/core/config/app_config.dart';
import 'package:runvibe_mobile/core/network/auth_interceptor.dart';

Dio createDio(AuthInterceptor authInterceptor) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(authInterceptor);
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
      ),
    );
  }
  return dio;
}
