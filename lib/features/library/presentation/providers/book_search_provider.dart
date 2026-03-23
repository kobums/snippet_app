import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/library/domain/usecases/search_books_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';

class BookSearchState {
  final List<BookSearchDto> results;
  final bool isSearching;
  final bool isLoadingMore;
  final int currentPage;
  final String currentQuery;
  final AppError? error;

  BookSearchState({
    this.results = const [],
    this.isSearching = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.currentQuery = '',
    this.error,
  });

  BookSearchState copyWith({
    List<BookSearchDto>? results,
    bool? isSearching,
    bool? isLoadingMore,
    int? currentPage,
    String? currentQuery,
    AppError? error,
    bool clearError = false,
  }) {
    return BookSearchState(
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      currentQuery: currentQuery ?? this.currentQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookSearchNotifier extends Notifier<BookSearchState> {
  late final SearchBooksUseCase _searchUseCase;

  @override
  BookSearchState build() {
    _searchUseCase = ref.read(searchBooksUseCaseProvider);
    return BookSearchState();
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = BookSearchState(); // Reset
      return;
    }

    state = state.copyWith(
      isSearching: true,
      currentQuery: trimmedQuery,
      currentPage: 1,
      clearError: true,
    );

    final result = await _searchUseCase(trimmedQuery, 1);

    result.when(
      success: (results) {
        state = state.copyWith(
          results: results,
          isSearching: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isSearching: false,
          error: error,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.currentQuery.isEmpty ||
        state.isLoadingMore ||
        state.isSearching) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    final result = await _searchUseCase(
      state.currentQuery,
      state.currentPage + 1,
    );

    result.when(
      success: (results) {
        if (results.isEmpty) {
          // No more results
          state = state.copyWith(isLoadingMore: false);
        } else {
          state = state.copyWith(
            results: [...state.results, ...results],
            currentPage: state.currentPage + 1,
            isLoadingMore: false,
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          isLoadingMore: false,
          error: error,
        );
      },
    );
  }

  void clearSearch() {
    state = BookSearchState();
  }
}

final bookSearchProvider =
    NotifierProvider<BookSearchNotifier, BookSearchState>(() {
  return BookSearchNotifier();
});
