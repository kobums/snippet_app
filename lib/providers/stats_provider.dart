import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats.dart';
import '../services/stats_api_service.dart';
import 'snippet_provider.dart';

class StatsState {
  final List<MonthlyStatsDto> monthlyStats;
  final List<YearlyStatsDto> yearlyStats;
  final List<CategoryStatsDto> categoryStats;
  final ReadingInsightsDto? insights;
  final bool isLoading;
  final String? error;
  final int selectedYear;

  StatsState({
    this.monthlyStats = const [],
    this.yearlyStats = const [],
    this.categoryStats = const [],
    this.insights,
    this.isLoading = false,
    this.error,
    int? selectedYear,
  }) : selectedYear = selectedYear ?? DateTime.now().year;

  StatsState copyWith({
    List<MonthlyStatsDto>? monthlyStats,
    List<YearlyStatsDto>? yearlyStats,
    List<CategoryStatsDto>? categoryStats,
    ReadingInsightsDto? insights,
    bool? isLoading,
    String? error,
    int? selectedYear,
  }) {
    return StatsState(
      monthlyStats: monthlyStats ?? this.monthlyStats,
      yearlyStats: yearlyStats ?? this.yearlyStats,
      categoryStats: categoryStats ?? this.categoryStats,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class StatsNotifier extends Notifier<StatsState> {
  @override
  StatsState build() {
    final now = DateTime.now();
    // Auto-load stats on initialization
    Future.microtask(() => loadAllStats());
    return StatsState(selectedYear: now.year);
  }

  /// Load all stats for current year
  Future<void> loadAllStats([int? year]) async {
    final targetYear = year ?? state.selectedYear;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
    );

    try {
      final api = ref.read(statsApiProvider);

      // Load all stats in parallel
      final results = await Future.wait([
        api.getMonthlyStats(targetYear),
        api.getYearlyStats(),
        api.getCategoryStats(targetYear),
        api.getReadingInsights(targetYear),
      ]);

      state = state.copyWith(
        monthlyStats: results[0] as List<MonthlyStatsDto>,
        yearlyStats: results[1] as List<YearlyStatsDto>,
        categoryStats: results[2] as List<CategoryStatsDto>,
        insights: results[3] as ReadingInsightsDto,
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

  /// Load monthly stats only
  Future<void> loadMonthlyStats([int? year]) async {
    final targetYear = year ?? state.selectedYear;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
    );

    try {
      final api = ref.read(statsApiProvider);
      final monthlyStats = await api.getMonthlyStats(targetYear);

      state = state.copyWith(
        monthlyStats: monthlyStats,
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

  /// Load yearly stats only
  Future<void> loadYearlyStats() async {
    state = state.copyWith(isLoading: true);

    try {
      final api = ref.read(statsApiProvider);
      final yearlyStats = await api.getYearlyStats();

      state = state.copyWith(
        yearlyStats: yearlyStats,
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

  /// Load category stats only
  Future<void> loadCategoryStats([int? year]) async {
    final targetYear = year ?? state.selectedYear;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
    );

    try {
      final api = ref.read(statsApiProvider);
      final categoryStats = await api.getCategoryStats(targetYear);

      state = state.copyWith(
        categoryStats: categoryStats,
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

  /// Load insights only
  Future<void> loadInsights([int? year]) async {
    final targetYear = year ?? state.selectedYear;

    state = state.copyWith(
      isLoading: true,
      selectedYear: targetYear,
    );

    try {
      final api = ref.read(statsApiProvider);
      final insights = await api.getReadingInsights(targetYear);

      state = state.copyWith(
        insights: insights,
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

  /// Set selected year and reload stats
  Future<void> setSelectedYear(int year) async {
    await loadAllStats(year);
  }

  /// Refresh all stats for current year
  Future<void> refreshStats() async {
    await loadAllStats();
  }
}

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(() {
  return StatsNotifier();
});

// API service provider
final statsApiProvider = Provider<StatsApiService>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return StatsApiService(dio);
});
