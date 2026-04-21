import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';

class FetchSessionsByBookUseCase {
  final ReadingSessionRepository _repository;

  FetchSessionsByBookUseCase(this._repository);

  Future<Result<List<ReadingSessionDto>>> call(int userBookId) {
    return _repository.getSessionsByBook(userBookId);
  }
}
