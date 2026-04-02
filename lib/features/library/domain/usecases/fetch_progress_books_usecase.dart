import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class FetchProgressBooksUseCase {
  final UserBookRepository _repository;

  FetchProgressBooksUseCase(this._repository);

  Future<Result<List<UserBookDto>>> call([int? year, int? month]) {
    return _repository.getProgressUserBooks(year, month);
  }
}
