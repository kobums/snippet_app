import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class FetchAllBooksUseCase {
  final UserBookRepository _repository;

  FetchAllBooksUseCase(this._repository);

  Future<Result<List<UserBookDto>>> call() {
    return _repository.getMonthlyUserBooks();
  }
}
