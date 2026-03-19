import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';

abstract class StatsRepository {
  Future<Result<List<MonthlyStatsDto>>> getMonthlyStats(int year);
  Future<Result<List<YearlyStatsDto>>> getYearlyStats();
  Future<Result<List<CategoryStatsDto>>> getCategoryStats(int year);
  Future<Result<ReadingInsightsDto>> getReadingInsights(int year);
}
