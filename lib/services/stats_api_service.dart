import 'package:dio/dio.dart';
import '../models/stats.dart';

class StatsApiService {
  final Dio _dio;

  StatsApiService(this._dio);

  /// Get monthly stats for a specific year
  Future<List<MonthlyStatsDto>> getMonthlyStats(int year) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/userbooks/stats/monthly',
        queryParameters: {'year': year},
      );

      return (response.data ?? [])
          .map((json) => MonthlyStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '월별 통계를 불러오는데 실패했습니다',
      );
    }
  }

  /// Get yearly stats (all years)
  Future<List<YearlyStatsDto>> getYearlyStats() async {
    try {
      final response = await _dio.get<List<dynamic>>('/userbooks/stats/yearly');

      return (response.data ?? [])
          .map((json) => YearlyStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '연도별 통계를 불러오는데 실패했습니다',
      );
    }
  }

  /// Get category stats for a specific year
  Future<List<CategoryStatsDto>> getCategoryStats(int year) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/userbooks/stats/category',
        queryParameters: {'year': year},
      );

      return (response.data ?? [])
          .map((json) => CategoryStatsDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '카테고리 통계를 불러오는데 실패했습니다',
      );
    }
  }

  /// Get reading insights for a specific year
  Future<ReadingInsightsDto> getReadingInsights(int year) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/userbooks/stats/insights',
        queryParameters: {'year': year},
      );

      return ReadingInsightsDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? '독서 인사이트를 불러오는데 실패했습니다',
      );
    }
  }
}
