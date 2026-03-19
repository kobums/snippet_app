import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';

abstract class UserBookRepository {
  Future<Result<List<UserBookDto>>> getMonthlyUserBooks([int? year, int? month]);
  Future<Result<int>> addUserBook(Map<String, dynamic> bookData);
  Future<Result<void>> patchUserBook(int id, Map<String, dynamic> updates);
  Future<Result<void>> deleteUserBook(int id);
}
