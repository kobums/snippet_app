import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/dashboard/data/datasources/calendar_share_datasource.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/shareable_reading_calendar.dart';
import 'package:snippet_app/features/dashboard/dashboard_providers.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_monthly_books_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';
import 'package:snippet_app/core/result/result.dart';

class CalendarState {
  final int selectedYear;
  final int selectedMonth;
  final List<UserBookDto> books;
  final bool isLoading;
  final bool isSaving;
  final bool isSharing;

  CalendarState({
    int? selectedYear,
    int? selectedMonth,
    this.books = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isSharing = false,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  CalendarState copyWith({
    int? selectedYear,
    int? selectedMonth,
    List<UserBookDto>? books,
    bool? isLoading,
    bool? isSaving,
    bool? isSharing,
  }) {
    return CalendarState(
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  late final CalendarShareService _shareService;
  late final FetchMonthlyBooksUseCase _fetchMonthlyBooksUseCase;

  @override
  CalendarState build() {
    _shareService = ref.read(calendarShareServiceProvider);
    _fetchMonthlyBooksUseCase = ref.read(fetchMonthlyBooksUseCaseProvider);
    Future.microtask(() => loadBooks(
      DateTime.now().year,
      DateTime.now().month,
    ));
    return CalendarState();
  }

  Future<void> setMonth(int year, int month) async {
    state = state.copyWith(
      selectedYear: year,
      selectedMonth: month,
      isLoading: true,
    );

    final result = await _fetchMonthlyBooksUseCase(year, month);
    result.when(
      success: (books) {
        state = state.copyWith(books: books, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  Future<void> loadBooks(int year, int month) async {
    state = state.copyWith(isLoading: true);

    final result = await _fetchMonthlyBooksUseCase(year, month);
    result.when(
      success: (books) {
        state = state.copyWith(books: books, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  Future<void> shareCalendar(
    BuildContext context,
    List<UserBookDto> completedBooks, {
    bool showStats = false,
    bool isDark = false,
  }) async {
    state = state.copyWith(isSharing: true);
    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: state.selectedYear,
        month: state.selectedMonth,
        showStats: showStats,
        isDark: isDark,
      );
      await _shareService.captureAndShare(
        context,
        calendarWidget,
        state.selectedYear,
        state.selectedMonth,
      );
    } finally {
      state = state.copyWith(isSharing: false);
    }
  }

  Future<void> saveToGallery(
    BuildContext context,
    List<UserBookDto> completedBooks, {
    bool showStats = false,
    bool isDark = false,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: state.selectedYear,
        month: state.selectedMonth,
        showStats: showStats,
        isDark: isDark,
      );
      await _shareService.captureAndSaveToGallery(
        context,
        calendarWidget,
        state.selectedYear,
        state.selectedMonth,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(() {
  return CalendarNotifier();
});
