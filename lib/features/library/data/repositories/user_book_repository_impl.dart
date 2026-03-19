import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/datasources/user_book_remote_datasource.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';

class UserBookRepositoryImpl implements UserBookRepository {
  final UserBookRemoteDataSource _remoteDataSource;

  UserBookRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<UserBookDto>>> getMonthlyUserBooks([int? year, int? month]) async {
    try {
      final books = await _remoteDataSource.getMonthlyUserBooks(year, month);
      return Success(books);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<int>> addUserBook(Map<String, dynamic> bookData) async {
    try {
      final id = await _remoteDataSource.addUserBook(bookData);
      return Success(id);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> patchUserBook(int id, Map<String, dynamic> updates) async {
    try {
      await _remoteDataSource.patchUserBook(id, updates);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> deleteUserBook(int id) async {
    try {
      await _remoteDataSource.deleteUserBook(id);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
