import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';

class FetchInsightsUseCase {
  final StatsRepository _repository;

  FetchInsightsUseCase(this._repository);

  Future<Result<ReadingInsightsDto>> call(int year) {
    return _repository.getReadingInsights(year);
  }
}
