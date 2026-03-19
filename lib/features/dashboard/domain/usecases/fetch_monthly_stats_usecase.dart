import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';

class FetchMonthlyStatsUseCase {
  final StatsRepository _repository;

  FetchMonthlyStatsUseCase(this._repository);

  Future<Result<List<MonthlyStatsDto>>> call(int year) {
    return _repository.getMonthlyStats(year);
  }
}
