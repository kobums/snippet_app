import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class UpdateBookUseCase {
  final UserBookRepository _repository;

  UpdateBookUseCase(this._repository);

  Future<Result<void>> call(int id, Map<String, dynamic> updates) {
    return _repository.patchUserBook(id, updates);
  }
}
