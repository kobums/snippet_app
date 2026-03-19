import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class DeleteBookUseCase {
  final UserBookRepository _repository;

  DeleteBookUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteUserBook(id);
  }
}
