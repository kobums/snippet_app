import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

abstract class RecordRemoteDataSource {
  Future<List<RecordDto>> getRecordsByBook(int bookId, {RecordType? type});
  Future<List<RecordDto>> getMonthlyRecords(int year, int month, {RecordType? type});
  Future<int> createRecord(int bookId, RecordAddRequestDto data);
  Future<void> patchRecord(int id, Map<String, dynamic> updates);
  Future<void> deleteRecord(int id);
}

class RecordRemoteDataSourceImpl implements RecordRemoteDataSource {
  final Dio _dio;

  RecordRemoteDataSourceImpl(this._dio);

  @override
  Future<List<RecordDto>> getRecordsByBook(int bookId, {RecordType? type}) async {
    try {
      final params = <String, dynamic>{
        'bookId': bookId,
        if (type != null) 'type': type.toJson(),
      };

      final response = await _dio.get(
        ApiConstants.recordsByBook,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => RecordDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<RecordDto>> getMonthlyRecords(int year, int month, {RecordType? type}) async {
    try {
      final params = <String, dynamic>{
        'year': year,
        'month': month,
        if (type != null) 'type': type.toJson(),
      };

      final response = await _dio.get(
        ApiConstants.recordsMonthly,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => RecordDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<int> createRecord(int bookId, RecordAddRequestDto data) async {
    try {
      final response = await _dio.post(
        ApiConstants.records,
        data: {
          'bookId': bookId,
          ...data.toJson(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'] as int;
      }
      throw ErrorHandler.handleDioError(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<void> patchRecord(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.records}/$id',
        data: updates,
      );

      if (response.statusCode != 200) {
        throw ErrorHandler.handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<void> deleteRecord(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.records}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ErrorHandler.handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
