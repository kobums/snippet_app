import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';

abstract class BookRepository {
  Future<Result<List<BookSearchDto>>> searchBooks(String query, int page);
}
