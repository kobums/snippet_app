import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';

class FetchCategoryStatsUseCase {
  final StatsRepository _repository;

  FetchCategoryStatsUseCase(this._repository);

  Future<Result<List<CategoryStatsDto>>> call(int year) {
    return _repository.getCategoryStats(year);
  }
}
