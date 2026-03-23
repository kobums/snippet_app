import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/dashboard/data/datasources/calendar_share_datasource.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/shareable_reading_calendar.dart';
import 'package:snippet_app/features/dashboard/dashboard_providers.dart';

class CalendarState {
  final int selectedYear;
  final int selectedMonth;
  final bool isSaving;
  final bool isSharing;

  CalendarState({
    int? selectedYear,
    int? selectedMonth,
    this.isSaving = false,
    this.isSharing = false,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  CalendarState copyWith({
    int? selectedYear,
    int? selectedMonth,
    bool? isSaving,
    bool? isSharing,
  }) {
    return CalendarState(
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  late final CalendarShareService _shareService;

  @override
  CalendarState build() {
    _shareService = ref.read(calendarShareServiceProvider);
    return CalendarState();
  }

  void setMonth(int year, int month) {
    state = state.copyWith(selectedYear: year, selectedMonth: month);
  }

  Future<void> shareCalendar(
    BuildContext context,
    List<UserBookDto> completedBooks,
  ) async {
    state = state.copyWith(isSharing: true);
    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: state.selectedYear,
        month: state.selectedMonth,
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
    List<UserBookDto> completedBooks,
  ) async {
    state = state.copyWith(isSaving: true);
    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: state.selectedYear,
        month: state.selectedMonth,
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
