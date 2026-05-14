import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/streak.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';

class FetchStreakUseCase {
  final ReadingSessionRepository _repository;

  FetchStreakUseCase(this._repository);

  Future<Result<StreakDto>> call() => _repository.getStreak();
}
