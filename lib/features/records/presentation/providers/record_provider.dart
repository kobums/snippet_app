import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/domain/usecases/add_record_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/delete_record_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/fetch_monthly_records_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/fetch_records_by_book_usecase.dart';
import 'package:snippet_app/features/records/domain/usecases/update_record_usecase.dart';
import 'package:snippet_app/features/records/records_providers.dart';

class RecordState {
  final List<RecordDto> allRecords;
  final bool isLoading;
  final AppError? error;
  final RecordType? selectedType;
  final int selectedYear;
  final int selectedMonth;

  RecordState({
    this.allRecords = const [],
    this.isLoading = false,
    this.error,
    this.selectedType,
    int? selectedYear,
    int? selectedMonth,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  /// Filtered records by selectedType
  List<RecordDto> get records {
    if (selectedType == null) return allRecords;
    return allRecords.where((r) => r.type == selectedType).toList();
  }

  RecordState copyWith({
    List<RecordDto>? allRecords,
    bool? isLoading,
    AppError? error,
    RecordType? selectedType,
    bool clearSelectedType = false,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return RecordState(
      allRecords: allRecords ?? this.allRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class RecordNotifier extends Notifier<RecordState> {
  late final FetchMonthlyRecordsUseCase _fetchMonthlyRecordsUseCase;
  late final FetchRecordsByBookUseCase _fetchRecordsByBookUseCase;
  late final AddRecordUseCase _addRecordUseCase;
  late final UpdateRecordUseCase _updateRecordUseCase;
  late final DeleteRecordUseCase _deleteRecordUseCase;

  @override
  RecordState build() {
    _fetchMonthlyRecordsUseCase = ref.read(fetchMonthlyRecordsUseCaseProvider);
    _fetchRecordsByBookUseCase = ref.read(fetchRecordsByBookUseCaseProvider);
    _addRecordUseCase = ref.read(addRecordUseCaseProvider);
    _updateRecordUseCase = ref.read(updateRecordUseCaseProvider);
    _deleteRecordUseCase = ref.read(deleteRecordUseCaseProvider);

    final now = DateTime.now();
    Future.microtask(() => loadMonthlyRecords());
    return RecordState(
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  /// Load monthly records (fetches all types at once)
  Future<void> loadMonthlyRecords([int? year, int? month]) async {
    final targetYear = year ?? state.selectedYear;
    final targetMonth = month ?? state.selectedMonth;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
      selectedMonth: targetMonth,
    );

    final result = await _fetchMonthlyRecordsUseCase(targetYear, targetMonth);
    result.when(
      success: (records) {
        state = state.copyWith(
          allRecords: records,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
      },
    );
  }

  /// Load records by book ID, optionally filtered by type
  Future<void> loadRecordsByBook(int bookId, {RecordType? type}) async {
    state = state.copyWith(isLoading: true);

    final result = await _fetchRecordsByBookUseCase(bookId, type: type);
    result.when(
      success: (records) {
        state = state.copyWith(
          allRecords: records,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
      },
    );
  }

  /// Set selected month and reload records
  Future<void> setSelectedMonth(int year, int month) async {
    await loadMonthlyRecords(year, month);
  }

  /// Set selected type filter (local only, no API call)
  void setSelectedType(RecordType? type) {
    state = state.copyWith(
      selectedType: type,
      clearSelectedType: type == null,
    );
  }

  /// Add a new record
  Future<void> addRecord(int bookId, RecordAddRequestDto data) async {
    final result = await _addRecordUseCase(bookId, data);
    result.when(
      success: (_) {
        loadMonthlyRecords();
      },
      failure: (error) {
        state = state.copyWith(error: error);
      },
    );
  }

  /// Update an existing record (optimistic update with rollback)
  Future<void> updateRecord(int id, Map<String, dynamic> updates) async {
    final originalRecords = state.allRecords;

    // Optimistic update
    state = state.copyWith(
      allRecords: state.allRecords.map((r) {
        if (r.id == id) {
          return r.copyWith(
            text: updates['text'] as String? ?? r.text,
            tag: updates['tag'] as String? ?? r.tag,
            relatedPage: updates['relatedPage'] as int? ?? r.relatedPage,
          );
        }
        return r;
      }).toList(),
    );

    final result = await _updateRecordUseCase(id, updates);
    result.when(
      success: (_) {
        // Optimistic update already applied
      },
      failure: (error) {
        // Rollback on failure
        state = state.copyWith(
          allRecords: originalRecords,
          error: error,
        );
      },
    );
  }

  /// Delete a record (optimistic update with rollback)
  Future<void> deleteRecord(int id) async {
    final originalRecords = state.allRecords;

    // Optimistic delete
    state = state.copyWith(
      allRecords: state.allRecords.where((r) => r.id != id).toList(),
    );

    final result = await _deleteRecordUseCase(id);
    result.when(
      success: (_) {
        // Optimistic delete already applied
      },
      failure: (error) {
        // Rollback on failure
        state = state.copyWith(
          allRecords: originalRecords,
          error: error,
        );
      },
    );
  }

  /// Refresh current records
  Future<void> refreshRecords() async {
    await loadMonthlyRecords();
  }
}

final recordProvider = NotifierProvider<RecordNotifier, RecordState>(() {
  return RecordNotifier();
});
