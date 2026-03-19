import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/features/library/domain/repositories/book_repository.dart';

class SearchBooksUseCase {
  final BookRepository _repository;

  SearchBooksUseCase(this._repository);

  Future<Result<List<BookSearchDto>>> call(String query, int page) {
    return _repository.searchBooks(query, page);
  }
}
