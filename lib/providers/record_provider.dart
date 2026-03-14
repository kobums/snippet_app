import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record.dart';
import '../services/record_api_service.dart';
import 'snippet_provider.dart';

class RecordState {
  final List<RecordDto> records;
  final bool isLoading;
  final String? error;
  final RecordType? selectedType;
  final int selectedYear;
  final int selectedMonth;

  RecordState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    this.selectedType,
    int? selectedYear,
    int? selectedMonth,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  RecordState copyWith({
    List<RecordDto>? records,
    bool? isLoading,
    String? error,
    RecordType? selectedType,
    bool clearSelectedType = false,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return RecordState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class RecordNotifier extends Notifier<RecordState> {
  @override
  RecordState build() {
    final now = DateTime.now();
    // Auto-load records on initialization
    Future.microtask(() => loadMonthlyRecords());
    return RecordState(
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  /// Load monthly records, optionally filtered by type
  Future<void> loadMonthlyRecords([int? year, int? month, RecordType? type]) async {
    final targetYear = year ?? state.selectedYear;
    final targetMonth = month ?? state.selectedMonth;
    final targetType = type ?? state.selectedType;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
      selectedMonth: targetMonth,
      selectedType: targetType,
      clearSelectedType: type == null && state.selectedType == null,
    );

    try {
      final api = ref.read(recordApiProvider);
      final records = await api.getMonthlyRecords(
        targetYear,
        targetMonth,
        type: targetType,
      );

      state = state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Load records by book ID, optionally filtered by type
  Future<void> loadRecordsByBook(int bookId, {RecordType? type}) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = ref.read(recordApiProvider);
      final records = await api.getRecordsByBook(bookId, type: type);

      state = state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Set selected month and reload records
  Future<void> setSelectedMonth(int year, int month) async {
    await loadMonthlyRecords(year, month);
  }

  /// Set selected type filter and reload records
  Future<void> setSelectedType(RecordType? type) async {
    await loadMonthlyRecords(state.selectedYear, state.selectedMonth, type);
  }

  /// Add a new record (optimistic update)
  Future<void> addRecord(int bookId, RecordAddRequestDto data) async {
    try {
      final api = ref.read(recordApiProvider);
      await api.createRecord(bookId, data);

      // Reload records to get the new one with all server data
      await loadMonthlyRecords();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Update an existing record
  Future<void> updateRecord(int id, Map<String, dynamic> updates) async {
    // Optimistic update
    final originalRecords = state.records;
    state = state.copyWith(
      records: state.records.map((r) {
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

    try {
      final api = ref.read(recordApiProvider);
      await api.patchRecord(id, updates);
    } catch (e) {
      // Rollback on error
      state = state.copyWith(
        records: originalRecords,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Delete a record
  Future<void> deleteRecord(int id) async {
    // Optimistic update
    final originalRecords = state.records;
    state = state.copyWith(
      records: state.records.where((r) => r.id != id).toList(),
    );

    try {
      final api = ref.read(recordApiProvider);
      await api.deleteRecord(id);
    } catch (e) {
      // Rollback on error
      state = state.copyWith(
        records: originalRecords,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Refresh current records
  Future<void> refreshRecords() async {
    await loadMonthlyRecords();
  }
}

final recordProvider = NotifierProvider<RecordNotifier, RecordState>(() {
  return RecordNotifier();
});

// API service provider
final recordApiProvider = Provider<RecordApiService>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return RecordApiService(dio);
});
