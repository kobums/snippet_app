import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_monthly_books_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';

class DashboardStatsState {
  final List<UserBookDto> books;
  final bool isLoading;
  final int selectedYear;
  final int selectedMonth;

  DashboardStatsState({
    this.books = const [],
    this.isLoading = false,
    int? selectedYear,
    int? selectedMonth,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  DashboardStatsState copyWith({
    List<UserBookDto>? books,
    bool? isLoading,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return DashboardStatsState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class DashboardStatsNotifier extends Notifier<DashboardStatsState> {
  late final FetchMonthlyBooksUseCase _fetchMonthlyBooksUseCase;

  @override
  DashboardStatsState build() {
    _fetchMonthlyBooksUseCase = ref.read(fetchMonthlyBooksUseCaseProvider);
    Future.microtask(() => loadBooks());
    return DashboardStatsState();
  }

  Future<void> loadBooks([int? year, int? month]) async {
    final y = year ?? DateTime.now().year;
    final m = month ?? DateTime.now().month;

    state = state.copyWith(isLoading: true, selectedYear: y, selectedMonth: m);

    final result = await _fetchMonthlyBooksUseCase(y, m);
    result.when(
      success: (books) {
        state = state.copyWith(books: books, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void setSelectedMonth(int year, int month) {
    loadBooks(year, month);
  }

  Future<void> refreshBooks() async {
    await loadBooks(state.selectedYear, state.selectedMonth);
  }

  /// 낙관적 업데이트: 서버 응답 없이 로컬 state 즉시 업데이트
  void updateBookLocally(UserBookDto updatedBook) {
    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == updatedBook.id) return updatedBook;
        return b;
      }).toList(),
    );
  }
}

final dashboardStatsProvider =
    NotifierProvider<DashboardStatsNotifier, DashboardStatsState>(() {
  return DashboardStatsNotifier();
});
