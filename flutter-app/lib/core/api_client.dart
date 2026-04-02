import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

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

  Future<dynamic> getBooks(String accessToken) async {
    try {
      final base = await _baseUrl();
      Response response = await _dio.get(
        '${base}books',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Network error', 'results': []};
    }
  }

  /// `POST /api/books` — multipart (`file` or `generated_file_path` required per API).
  /// Provide either [imageFilePath] (mobile/desktop) or [imageBytes] + [imageFilename] (e.g. web).
  Future<dynamic> createBook({
    required String accessToken,
    required String name,
    required String description,
    required int genreId,
    required int inventoryTotalQty,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFilename,
  }) async {
    if (imageFilePath == null &&
        (imageBytes == null || imageFilename == null)) {
      return {
        'success': false,
        'message': 'Missing image file or bytes for createBook',
      };
    }
    try {
      final base = await _baseUrl();
      final MultipartFile file;
      if (imageFilePath != null) {
        file = await MultipartFile.fromFile(
          imageFilePath,
          filename: p.basename(imageFilePath),
        );
      } else {
        file = MultipartFile.fromBytes(
          imageBytes!,
          filename: imageFilename!,
        );
      }
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'genre_id': genreId,
        'inventory_total_qty': inventoryTotalQty,
        'file': file,
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '${base}books',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Network error'};
    }
  }

  /// `PUT /api/books/{id}` — JSON body.
  Future<dynamic> updateBook({
    required String accessToken,
    required int id,
    required String name,
    required String description,
    required int genreId,
    required int inventoryTotalQty,
  }) async {
    try {
      final base = await _baseUrl();
      final response = await _dio.put<Map<String, dynamic>>(
        '${base}books/$id',
        data: {
          'name': name,
          'description': description,
          'genre_id': genreId,
          'inventory_total_qty': inventoryTotalQty,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Network error'};
    }
  }

  /// `DELETE /api/books/{id}`.
  Future<dynamic> deleteBook({
    required String accessToken,
    required int id,
  }) async {
    try {
      final base = await _baseUrl();
      final response = await _dio.delete<Map<String, dynamic>>(
        '${base}books/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Network error'};
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
