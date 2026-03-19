import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class AddBookUseCase {
  final UserBookRepository _repository;

  AddBookUseCase(this._repository);

  Future<Result<int>> call(Map<String, dynamic> bookData) {
    return _repository.addUserBook(bookData);
  }
}
