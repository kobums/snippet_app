import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';

abstract class StatsRemoteDataSource {
  Future<List<MonthlyStatsDto>> getMonthlyStats(int year);
  Future<List<YearlyStatsDto>> getYearlyStats();
  Future<List<CategoryStatsDto>> getCategoryStats(int year);
  Future<ReadingInsightsDto> getReadingInsights(int year);
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final Dio _dio;

  StatsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<MonthlyStatsDto>> getMonthlyStats(int year) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.statsMonthly,
        queryParameters: {'year': year},
      );
      return (response.data ?? [])
          .map((json) =>
              MonthlyStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<YearlyStatsDto>> getYearlyStats() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.statsYearly,
      );
      return (response.data ?? [])
          .map((json) =>
              YearlyStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<CategoryStatsDto>> getCategoryStats(int year) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.statsCategory,
        queryParameters: {'year': year},
      );
      return (response.data ?? [])
          .map((json) =>
              CategoryStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<ReadingInsightsDto> getReadingInsights(int year) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.statsInsights,
        queryParameters: {'year': year},
      );
      return ReadingInsightsDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
