import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';

class SaveReadingSessionUseCase {
  final ReadingSessionRepository _repository;

  SaveReadingSessionUseCase(this._repository);

  Future<Result<int>> call(ReadingSessionAddRequestDto data) {
    return _repository.createSession(data);
  }
}
