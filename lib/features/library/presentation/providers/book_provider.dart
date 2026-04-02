import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/core/utils/temp_id_generator.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/domain/usecases/delete_book_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_progress_books_usecase.dart';
import 'package:snippet_app/features/library/domain/usecases/update_book_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';

class BookState {
  final List<UserBookDto> books;
  final bool isLoading;
  final int selectedYear;
  final int selectedMonth;
  final AppError? error;

  BookState({
    this.books = const [],
    this.isLoading = false,
    int? selectedYear,
    int? selectedMonth,
    this.error,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  BookState copyWith({
    List<UserBookDto>? books,
    bool? isLoading,
    int? selectedYear,
    int? selectedMonth,
    AppError? error,
  }) {
    return BookState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      error: error,
    );
  }
}

class BookNotifier extends Notifier<BookState> {
  late final FetchProgressBooksUseCase _fetchProgressBooksUseCase;
  late final UpdateBookUseCase _updateBookUseCase;
  late final DeleteBookUseCase _deleteBookUseCase;

  @override
  BookState build() {
    _fetchProgressBooksUseCase = ref.read(fetchProgressBooksUseCaseProvider);
    _updateBookUseCase = ref.read(updateBookUseCaseProvider);
    _deleteBookUseCase = ref.read(deleteBookUseCaseProvider);
    Future.microtask(() => loadDashboard());
    return BookState();
  }

  Future<void> loadDashboard([int? year, int? month]) async {
    final y = year ?? DateTime.now().year;
    final m = month ?? DateTime.now().month;

    state = state.copyWith(isLoading: true, selectedYear: y, selectedMonth: m);

    final result = await _fetchProgressBooksUseCase(y, m);
    result.when(
      success: (books) {
        state = state.copyWith(books: books, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );
  }

  void setSelectedMonth(int year, int month) {
    loadDashboard(year, month);
  }

  Future<void> updateStatus(int id, BookStatus status) async {
    final oldBooks = state.books;
    final now = DateTime.now().toIso8601String();

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          // 읽는중으로 변경 시, 대기중에서 변경되거나 시작일이 없으면 현재 시간으로 설정
          final shouldUpdateStartDate = status == BookStatus.reading &&
              (b.status == BookStatus.waiting || b.startDate.isEmpty);

          return b.copyWith(
            status: status,
            startDate: shouldUpdateStartDate ? now : b.startDate,
            endDate: (status == BookStatus.completed || status == BookStatus.dropped) ? now : b.endDate,
            readPage: status == BookStatus.completed ? b.totalPage : b.readPage,
          );
        }
        return b;
      }).toList(),
    );

    final result = await _updateBookUseCase(id, {'status': status.toJson()});
    result.when(
      success: (_) => _updateWidgetStats(),
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  Future<void> updateProgress(int id, int page) async {
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) return b.copyWith(readPage: page);
        return b;
      }).toList(),
    );

    final result = await _updateBookUseCase(id, {'readPage': page});
    result.when(
      success: (_) => _updateWidgetStats(),
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  Future<void> updateType(int id, BookType type) async {
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) return b.copyWith(type: type);
        return b;
      }).toList(),
    );

    final result = await _updateBookUseCase(id, {'type': type.toJson()});
    result.when(
      success: (_) {},
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  Future<void> updateStartDate(int id, String date) async {
    final oldBooks = state.books;
    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) return b.copyWith(startDate: date);
        return b;
      }).toList(),
    );

    final result = await _updateBookUseCase(id, {'startDate': date});
    result.when(
      success: (_) {},
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  Future<void> updateEndDate(int id, String date) async {
    final oldBooks = state.books;
    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) return b.copyWith(endDate: date);
        return b;
      }).toList(),
    );

    final result = await _updateBookUseCase(id, {'endDate': date});
    result.when(
      success: (_) {},
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  int addBookLocally(UserBookDto book) {
    final tempId = TempIdGenerator.generate();
    final newBook = book.copyWith(id: tempId);
    state = state.copyWith(books: [newBook, ...state.books]);
    return tempId;
  }

  void removeBookLocally(int id) {
    state = state.copyWith(
      books: state.books.where((b) => b.id != id).toList(),
    );
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

  void updateBookId(int tempId, int realId) {
    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == tempId) return b.copyWith(id: realId);
        return b;
      }).toList(),
    );
  }

  Future<void> deleteBook(int id) async {
    final oldBooks = state.books;
    removeBookLocally(id);

    final result = await _deleteBookUseCase(id);
    result.when(
      success: (_) => _updateWidgetStats(),
      failure: (error) {
        state = state.copyWith(books: oldBooks, error: error);
      },
    );
  }

  Future<void> refreshBooks() async {
    await loadDashboard(state.selectedYear, state.selectedMonth);
    _updateWidgetStats();
  }

  Future<void> _updateWidgetStats() async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      final completedThisMonth =
          state.books.where((b) => b.status == BookStatus.completed).length;
      final readingBooks =
          state.books.where((b) => b.status == BookStatus.reading).toList();
      final currentProgress = readingBooks.isNotEmpty
          ? (readingBooks.first.progress * 100).toInt()
          : 0;

      await HomeWidget.saveWidgetData<int>('completed_count', completedThisMonth);
      await HomeWidget.saveWidgetData<int>('current_progress', currentProgress);
      await HomeWidget.updateWidget(
        name: AppConstants.widgetProviderName,
        iOSName: AppConstants.widgetIosName,
      );
    } catch (_) {}
  }
}

final bookProvider = NotifierProvider<BookNotifier, BookState>(() {
  return BookNotifier();
});
