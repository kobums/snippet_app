import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record.dart';
import '../services/record_api_service.dart';
import 'snippet_provider.dart';

class RecordState {
  final List<RecordDto> allRecords;
  final bool isLoading;
  final String? error;
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
    String? error,
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

  /// Load monthly records (fetches all types at once)
  Future<void> loadMonthlyRecords([int? year, int? month]) async {
    final targetYear = year ?? state.selectedYear;
    final targetMonth = month ?? state.selectedMonth;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
      selectedMonth: targetMonth,
    );

    try {
      final api = ref.read(recordApiProvider);
      final records = await api.getMonthlyRecords(
        targetYear,
        targetMonth,
      );

      state = state.copyWith(
        allRecords: records,
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
        allRecords: records,
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

  /// Set selected type filter (local only, no API call)
  void setSelectedType(RecordType? type) {
    state = state.copyWith(
      selectedType: type,
      clearSelectedType: type == null,
    );
  }

  /// Add a new record
  Future<void> addRecord(int bookId, RecordAddRequestDto data) async {
    try {
      final api = ref.read(recordApiProvider);
      await api.createRecord(bookId, data);

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
    final originalRecords = state.allRecords;
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

    try {
      final api = ref.read(recordApiProvider);
      await api.patchRecord(id, updates);
    } catch (e) {
      state = state.copyWith(
        allRecords: originalRecords,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Delete a record
  Future<void> deleteRecord(int id) async {
    final originalRecords = state.allRecords;
    state = state.copyWith(
      allRecords: state.allRecords.where((r) => r.id != id).toList(),
    );

    try {
      final api = ref.read(recordApiProvider);
      await api.deleteRecord(id);
    } catch (e) {
      state = state.copyWith(
        allRecords: originalRecords,
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
