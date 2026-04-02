import 'package:dio/dio.dart';

import 'package:byu_590r_flutter_app/core/api_config.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<String> _baseUrl() => ApiConfig.getBaseUrl();

  Future<dynamic> registerUser(Map<String, dynamic>? data) async {
    try {
      final base = await _baseUrl();
      Response response = await _dio.post('${base}register', data: data);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'ErrorCode': 1, 'Message': 'Network error'};
    }
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final base = await _baseUrl();
      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
      });
      Response response = await _dio.post('${base}login', data: formData);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'success': false, 'message': 'Network error'};
    }
  }

  Future<dynamic> getUserProfileData(String accessToken) async {
    try {
      final base = await _baseUrl();
      Response response = await _dio.get(
        '${base}user',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'ErrorCode': 1, 'Message': 'Network error'};
    }
  }

  Future<dynamic> updateUserProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final base = await _baseUrl();
      Response response = await _dio.put(
        '${base}user',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'ErrorCode': 1, 'Message': 'Network error'};
    }
  }

  Future<dynamic> logout(String accessToken) async {
    try {
      final base = await _baseUrl();
      Response response = await _dio.post('${base}logout');
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'ErrorCode': 1, 'Message': 'Network error'};
    }
  }
}
