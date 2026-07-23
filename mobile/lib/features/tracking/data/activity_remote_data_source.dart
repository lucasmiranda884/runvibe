import 'package:dio/dio.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_request_dto.dart';

class ActivityRemoteDataSource {
  ActivityRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> create(ActivityRequestDTO request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'activities',
      data: request.toJson(),
    );
    return response.data ?? const {};
  }
}
