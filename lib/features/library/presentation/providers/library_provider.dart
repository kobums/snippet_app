import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_all_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/update_book_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';

class LibraryState {
  final List<UserBookDto> allBooks;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final AppError? error;

  LibraryState({
    this.allBooks = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  LibraryState copyWith({
    List<UserBookDto>? allBooks,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    AppError? error,
  }) {
    return LibraryState(
      allBooks: allBooks ?? this.allBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

class LibraryNotifier extends Notifier<LibraryState> {
  late final FetchAllBooksUseCase _fetchAllBooksUseCase;
  late final UpdateBookUseCase _updateBookUseCase;
  static const int _pageSize = 20;

  @override
  LibraryState build() {
    _fetchAllBooksUseCase = ref.read(fetchAllBooksUseCaseProvider);
    _updateBookUseCase = ref.read(updateBookUseCaseProvider);
    Future.microtask(() => loadAllBooks());
    return LibraryState();
  }

  Future<void> loadAllBooks() async {
    state = state.copyWith(
      isLoading: true,
      currentPage: 0,
      hasMore: true,
    );

    final result = await _fetchAllBooksUseCase(0, _pageSize);
    result.when(
      success: (books) {
        state = state.copyWith(
          allBooks: books,
          isLoading: false,
          hasMore: books.length == _pageSize,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );
  }

  Future<void> loadMoreBooks() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await _fetchAllBooksUseCase(nextPage, _pageSize);
    result.when(
      success: (books) {
        final updatedBooks = [...state.allBooks, ...books];
        state = state.copyWith(
          allBooks: updatedBooks,
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: books.length == _pageSize,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoadingMore: false, error: error);
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<UserBookDto> get filteredBooks {
    if (state.searchQuery.isEmpty) return state.allBooks;
    final query = state.searchQuery.toLowerCase();
    return state.allBooks.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  List<UserBookDto> get recentBooks {
    final sorted = List<UserBookDto>.from(filteredBooks);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a.createDate) ?? DateTime(1900);
      final bDate = DateTime.tryParse(b.createDate) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
    return sorted.take(5).toList();
  }

  List<UserBookDto> get readingBooks {
    return filteredBooks
        .where((book) => book.status == BookStatus.reading)
        .toList();
  }

  List<UserBookDto> get completedBooks {
    return filteredBooks
        .where((book) => book.status == BookStatus.completed)
        .toList();
  }

  List<UserBookDto> get borrowedBooks {
    return filteredBooks
        .where((book) => book.type == BookType.borrow)
        .toList();
  }

  List<UserBookDto> get wishlistBooks {
    return filteredBooks
        .where((book) => book.type == BookType.wish)
        .toList();
  }

  List<UserBookDto> getBooksHave() {
    return state.allBooks
        .where((book) => book.type == BookType.have)
        .toList();
  }

  List<UserBookDto> getBooksBorrow() {
    return state.allBooks
        .where((book) => book.type == BookType.borrow)
        .toList();
  }

  List<UserBookDto> getBooksWish() {
    return state.allBooks
        .where((book) => book.type == BookType.wish)
        .toList();
  }

  List<UserBookDto> searchInCategory(BookType type, String query) {
    final q = query.toLowerCase();
    return state.allBooks
        .where((book) => book.type == type)
        .where((book) =>
            book.title.toLowerCase().contains(q) ||
            book.author.toLowerCase().contains(q))
        .toList();
  }

  Future<void> refreshBooks() async {
    await loadAllBooks();
  }

  /// 낙관적 업데이트: 서버 응답 없이 로컬 state 즉시 업데이트
  void updateBookLocally(UserBookDto updatedBook) {
    state = state.copyWith(
      allBooks: state.allBooks.map((b) {
        if (b.id == updatedBook.id) return updatedBook;
        return b;
      }).toList(),
    );
  }

  Future<void> updateBookStatus(int id, BookStatus newStatus) async {
    final original = state.allBooks.firstWhere((b) => b.id == id);
    updateBookLocally(original.copyWith(status: newStatus));

    final result = await _updateBookUseCase(id, {'status': newStatus.toJson()});
    result.when(
      success: (_) {},
      failure: (_) => updateBookLocally(original),
    );
  }
}

final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(() {
  return LibraryNotifier();
});
