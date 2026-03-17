import 'package:dio/dio.dart';
import '../models/user_book.dart';

class UserBookApiService {
  final Dio _dio;

  UserBookApiService(this._dio);

  Future<List<UserBookDto>> getMonthlyUserBooks([int? year, int? month]) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        '/userbooks/monthly',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UserBookDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Get monthly books error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load books. Please try again.',
      );
    }
  }

  Future<int> addUserBook(Map<String, dynamic> bookData) async {
    try {
      final response = await _dio.post(
        '/userbooks',
        data: bookData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming the backend returns the created book with id
        final book = UserBookDto.fromJson(response.data);
        return book.id;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to add book',
      );
    } on DioException catch (e) {
      print('Add book error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add book. Please try again.',
      );
    }
  }

  Future<void> patchUserBook(int id, Map<String, dynamic> updates) async {
    try {
      print('📤 PATCH /userbooks/$id - Data: $updates');

      final response = await _dio.patch(
        '/userbooks/$id',
        data: updates,
      );

      print('📥 Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update book',
        );
      }
    } on DioException catch (e) {
      print('❌ Update book error: ${e.message}');
      print('   Response: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update book. Please try again.',
      );
    }
  }

  Future<void> deleteUserBook(int id) async {
    try {
      final response = await _dio.delete('/userbooks/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to delete book',
        );
      }
    } on DioException catch (e) {
      print('Delete book error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete book. Please try again.',
      );
    }
  }
}
