import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';

class FetchAllSessionsUseCase {
  final ReadingSessionRepository _repository;

  FetchAllSessionsUseCase(this._repository);

  Future<Result<List<ReadingSessionDto>>> call() {
    return _repository.getAllSessions();
  }
}
