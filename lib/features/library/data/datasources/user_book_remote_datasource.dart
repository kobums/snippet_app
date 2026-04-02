import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';

abstract class UserBookRemoteDataSource {
  Future<List<UserBookDto>> getMonthlyUserBooks([int? year, int? month]);
  Future<List<UserBookDto>> getProgressUserBooks([int? year, int? month]);
  Future<List<UserBookDto>> getAllUserBooksPaginated(int page, int size);
  Future<int> addUserBook(Map<String, dynamic> bookData);
  Future<void> patchUserBook(int id, Map<String, dynamic> updates);
  Future<void> deleteUserBook(int id);
}

class UserBookRemoteDataSourceImpl implements UserBookRemoteDataSource {
  final Dio _dio;

  UserBookRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserBookDto>> getMonthlyUserBooks([int? year, int? month]) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        ApiConstants.userbooksMonthly,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UserBookDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<UserBookDto>> getProgressUserBooks([int? year, int? month]) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        ApiConstants.userbooksProgress,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UserBookDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<UserBookDto>> getAllUserBooksPaginated(int page, int size) async {
    try {
      final response = await _dio.get(
        ApiConstants.userbooksAll,
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UserBookDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<int> addUserBook(Map<String, dynamic> bookData) async {
    try {
      final response = await _dio.post(
        ApiConstants.userbooks,
        data: bookData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final book = UserBookDto.fromJson(response.data);
        return book.id;
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
  Future<void> patchUserBook(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.userbooks}/$id',
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
  Future<void> deleteUserBook(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.userbooks}/$id');

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
