import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';

class FetchYearlyStatsUseCase {
  final StatsRepository _repository;

  FetchYearlyStatsUseCase(this._repository);

  Future<Result<List<YearlyStatsDto>>> call() {
    return _repository.getYearlyStats();
  }
}
