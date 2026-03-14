import 'package:dio/dio.dart';
import '../models/record.dart';

class RecordApiService {
  final Dio _dio;

  RecordApiService(this._dio);

  /// Get records by book ID, optionally filtered by type
  Future<List<RecordDto>> getRecordsByBook(
    int bookId, {
    RecordType? type,
  }) async {
    try {
      final params = {
        'bookId': bookId,
        if (type != null) 'type': type.toJson(),
      };

      final response = await _dio.get<List<dynamic>>(
        '/records/bybook',
        queryParameters: params,
      );

      return (response.data ?? [])
          .map((json) => RecordDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '기록을 불러오는데 실패했습니다',
      );
    }
  }

  /// Get monthly records, optionally filtered by type
  Future<List<RecordDto>> getMonthlyRecords(
    int year,
    int month, {
    RecordType? type,
  }) async {
    try {
      final params = {
        'year': year,
        'month': month,
        if (type != null) 'type': type.toJson(),
      };

      final response = await _dio.get<List<dynamic>>(
        '/records/monthly',
        queryParameters: params,
      );

      return (response.data ?? [])
          .map((json) => RecordDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '기록을 불러오는데 실패했습니다',
      );
    }
  }

  /// Create a new record
  Future<int> createRecord(
    int bookId,
    RecordAddRequestDto data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/records',
        data: {
          'bookId': bookId,
          ...data.toJson(),
        },
      );

      return response.data?['id'] as int;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '기록 추가에 실패했습니다',
      );
    }
  }

  /// Update an existing record
  Future<void> patchRecord(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _dio.patch(
        '/records/$id',
        data: updates,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '기록 수정에 실패했습니다',
      );
    }
  }

  /// Delete a record
  Future<void> deleteRecord(int id) async {
    try {
      await _dio.delete('/records/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '기록 삭제에 실패했습니다',
      );
    }
  }
}
