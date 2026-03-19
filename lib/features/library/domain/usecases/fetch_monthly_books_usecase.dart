import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class FetchMonthlyBooksUseCase {
  final UserBookRepository _repository;

  FetchMonthlyBooksUseCase(this._repository);

  Future<Result<List<UserBookDto>>> call([int? year, int? month]) {
    return _repository.getMonthlyUserBooks(year, month);
  }
}
