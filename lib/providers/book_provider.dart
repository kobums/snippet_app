import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../models/user_book.dart';
import '../services/user_book_api_service.dart';
import '../services/book_api_service.dart';
import 'snippet_provider.dart';
import '../utils/temp_id_generator.dart';

class BookState {
  final List<UserBookDto> books;
  final bool isLoading;
  final int selectedYear;
  final int selectedMonth;

  BookState({
    this.books = const [],
    this.isLoading = false,
    int? selectedYear,
    int? selectedMonth,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  BookState copyWith({
    List<UserBookDto>? books,
    bool? isLoading,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return BookState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class BookNotifier extends Notifier<BookState> {
  @override
  BookState build() {
    // Load dashboard on initialization
    Future.microtask(() => loadDashboard());
    return BookState();
  }

  Future<void> loadDashboard([int? year, int? month]) async {
    final y = year ?? DateTime.now().year;
    final m = month ?? DateTime.now().month;

    state = state.copyWith(
      isLoading: true,
      selectedYear: y,
      selectedMonth: m,
    );

    try {
      final api = ref.read(userBookApiProvider);
      final books = await api.getMonthlyUserBooks(y, m);
      state = state.copyWith(books: books, isLoading: false);
    } catch (e) {
      print('Load dashboard error: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void setSelectedMonth(int year, int month) {
    loadDashboard(year, month);
  }

  Future<void> updateStatus(int id, BookStatus status) async {
    // Optimistic update
    final oldBooks = state.books;
    final now = DateTime.now().toIso8601String();

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          return b.copyWith(
            status: status,
            endDate: (status == BookStatus.completed || status == BookStatus.dropped)
                ? now
                : b.endDate,
            readPage: status == BookStatus.completed ? b.totalPage : b.readPage,
          );
        }
        return b;
      }).toList(),
    );

    try {
      final api = ref.read(userBookApiProvider);
      await api.patchUserBook(id, {'status': status.toJson()});
      // Update widget after successful status change
      _updateWidgetStats();
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  Future<void> updateProgress(int id, int page) async {
    // Optimistic update
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          return b.copyWith(readPage: page);
        }
        return b;
      }).toList(),
    );

    try {
      final api = ref.read(userBookApiProvider);
      await api.patchUserBook(id, {'readPage': page});
      // Update widget after successful progress update
      _updateWidgetStats();
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  Future<void> updateType(int id, BookType type) async {
    // Optimistic update
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          return b.copyWith(type: type);
        }
        return b;
      }).toList(),
    );

    try {
      final api = ref.read(userBookApiProvider);
      await api.patchUserBook(id, {'type': type.toJson()});
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  Future<void> updateStartDate(int id, String date) async {
    // Optimistic update
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          return b.copyWith(startDate: date);
        }
        return b;
      }).toList(),
    );

    try {
      final api = ref.read(userBookApiProvider);
      await api.patchUserBook(id, {'startDate': date});
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  Future<void> updateEndDate(int id, String date) async {
    // Optimistic update
    final oldBooks = state.books;

    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == id) {
          return b.copyWith(endDate: date);
        }
        return b;
      }).toList(),
    );

    try {
      final api = ref.read(userBookApiProvider);
      await api.patchUserBook(id, {'endDate': date});
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  // Optimistic update helpers
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

  void updateBookId(int tempId, int realId) {
    state = state.copyWith(
      books: state.books.map((b) {
        if (b.id == tempId) {
          return b.copyWith(id: realId);
        }
        return b;
      }).toList(),
    );
  }

  Future<void> deleteBook(int id) async {
    // Optimistic update
    final oldBooks = state.books;
    removeBookLocally(id);

    try {
      final api = ref.read(userBookApiProvider);
      await api.deleteUserBook(id);
      // Update widget after successful deletion
      _updateWidgetStats();
    } catch (e) {
      // Rollback on error
      state = state.copyWith(books: oldBooks);
      rethrow;
    }
  }

  Future<void> refreshBooks() async {
    await loadDashboard(state.selectedYear, state.selectedMonth);
    // Update widget after refresh
    _updateWidgetStats();
  }

  // Update widget with reading statistics
  Future<void> _updateWidgetStats() async {
    try {
      await HomeWidget.setAppGroupId('group.com.gowoobro.snippet');

      // Calculate completed books this month
      final completedThisMonth = state.books
          .where((b) => b.status == BookStatus.completed)
          .length;

      // Get current reading progress
      final readingBooks = state.books
          .where((b) => b.status == BookStatus.reading)
          .toList();
      final currentProgress = readingBooks.isNotEmpty
          ? (readingBooks.first.progress * 100).toInt()
          : 0;

      // Save to widget
      await HomeWidget.saveWidgetData<int>('completed_count', completedThisMonth);
      await HomeWidget.saveWidgetData<int>('current_progress', currentProgress);

      await HomeWidget.updateWidget(
        name: 'SnippetWidgetProvider',
        iOSName: 'snippetWidget',
      );

      print('Widget stats updated from BookProvider: $completedThisMonth books, $currentProgress% progress');
    } catch (e) {
      print('Widget stats update error: $e');
    }
  }
}

final bookProvider = NotifierProvider<BookNotifier, BookState>(() {
  return BookNotifier();
});

// API service providers
final userBookApiProvider = Provider<UserBookApiService>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return UserBookApiService(dio);
});

final bookApiProvider = Provider<BookApiService>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return BookApiService(dio);
});
