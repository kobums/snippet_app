import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/library/data/datasources/book_remote_datasource.dart';
import 'package:snippet_app/features/library/data/datasources/user_book_remote_datasource.dart';
import 'package:snippet_app/features/library/data/repositories/book_repository_impl.dart';
import 'package:snippet_app/features/library/data/repositories/user_book_repository_impl.dart';
import 'package:snippet_app/features/library/domain/repositories/book_repository.dart';
import 'package:snippet_app/features/library/domain/repositories/user_book_repository.dart';
import 'package:snippet_app/features/library/domain/usecases/add_book_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/delete_book_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_all_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_monthly_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_progress_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/search_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/update_book_usecase.dart';

// DataSources
final userBookRemoteDataSourceProvider =
    Provider<UserBookRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return UserBookRemoteDataSourceImpl(dio);
});

final bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return BookRemoteDataSourceImpl(dio);
});

// Repositories
final userBookRepositoryProvider = Provider<UserBookRepository>((ref) {
  final remote = ref.read(userBookRemoteDataSourceProvider);
  return UserBookRepositoryImpl(remote);
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final remote = ref.read(bookRemoteDataSourceProvider);
  return BookRepositoryImpl(remote);
});

// UseCases
final fetchMonthlyBooksUseCaseProvider =
    Provider<FetchMonthlyBooksUseCase>((ref) {
  return FetchMonthlyBooksUseCase(ref.read(userBookRepositoryProvider));
});

final fetchProgressBooksUseCaseProvider =
    Provider<FetchProgressBooksUseCase>((ref) {
  return FetchProgressBooksUseCase(ref.read(userBookRepositoryProvider));
});

final fetchAllBooksUseCaseProvider = Provider<FetchAllBooksUseCase>((ref) {
  return FetchAllBooksUseCase(ref.read(userBookRepositoryProvider));
});

final addBookUseCaseProvider = Provider<AddBookUseCase>((ref) {
  return AddBookUseCase(ref.read(userBookRepositoryProvider));
});

final updateBookUseCaseProvider = Provider<UpdateBookUseCase>((ref) {
  return UpdateBookUseCase(ref.read(userBookRepositoryProvider));
});

final deleteBookUseCaseProvider = Provider<DeleteBookUseCase>((ref) {
  return DeleteBookUseCase(ref.read(userBookRepositoryProvider));
});

final searchBooksUseCaseProvider = Provider<SearchBooksUseCase>((ref) {
  return SearchBooksUseCase(ref.read(bookRepositoryProvider));
});
