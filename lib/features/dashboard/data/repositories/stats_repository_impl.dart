import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/datasources/stats_remote_datasource.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource _remoteDataSource;

  StatsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<MonthlyStatsDto>>> getMonthlyStats(int year) async {
    try {
      final stats = await _remoteDataSource.getMonthlyStats(year);
      return Success(stats);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<YearlyStatsDto>>> getYearlyStats() async {
    try {
      final stats = await _remoteDataSource.getYearlyStats();
      return Success(stats);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<CategoryStatsDto>>> getCategoryStats(int year) async {
    try {
      final stats = await _remoteDataSource.getCategoryStats(year);
      return Success(stats);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<ReadingInsightsDto>> getReadingInsights(int year) async {
    try {
      final insights = await _remoteDataSource.getReadingInsights(year);
      return Success(insights);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
