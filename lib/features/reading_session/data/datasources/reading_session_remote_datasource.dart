import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session_stats.dart';

abstract class ReadingSessionRemoteDataSource {
  Future<int> createSession(ReadingSessionAddRequestDto data);
  Future<List<ReadingSessionDto>> getAllSessions();
  Future<List<ReadingSessionDto>> getSessionsByBook(int userBookId);
  Future<ReadingSessionStatsDto> getStats(int userBookId);
}

class ReadingSessionRemoteDataSourceImpl implements ReadingSessionRemoteDataSource {
  final Dio _dio;

  ReadingSessionRemoteDataSourceImpl(this._dio);

  @override
  Future<int> createSession(ReadingSessionAddRequestDto data) async {
    try {
      final response = await _dio.post(
        ApiConstants.readingSessions,
        data: data.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as int;
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
  Future<List<ReadingSessionDto>> getAllSessions() async {
    try {
      final response = await _dio.get(ApiConstants.readingSessions);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => ReadingSessionDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<ReadingSessionDto>> getSessionsByBook(int userBookId) async {
    try {
      final response = await _dio.get(
        ApiConstants.readingSessionsByBook,
        queryParameters: {'userBookId': userBookId},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => ReadingSessionDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<ReadingSessionStatsDto> getStats(int userBookId) async {
    try {
      final response = await _dio.get(
        ApiConstants.readingSessionsStats,
        queryParameters: {'userBookId': userBookId},
      );
      if (response.statusCode == 200) {
        return ReadingSessionStatsDto.fromJson(response.data);
      }
      return ReadingSessionStatsDto.empty();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
