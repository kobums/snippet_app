import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/features/dashboard/dashboard_providers.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_category_stats_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_insights_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_monthly_stats_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_yearly_stats_usecase.dart';

class StatsState {
  final List<MonthlyStatsDto> monthlyStats;
  final List<YearlyStatsDto> yearlyStats;
  final List<CategoryStatsDto> categoryStats;
  final ReadingInsightsDto? insights;
  final bool isLoading;
  final AppError? error;
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
    AppError? error,
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
  late final FetchMonthlyStatsUseCase _fetchMonthlyStatsUseCase;
  late final FetchYearlyStatsUseCase _fetchYearlyStatsUseCase;
  late final FetchCategoryStatsUseCase _fetchCategoryStatsUseCase;
  late final FetchInsightsUseCase _fetchInsightsUseCase;

  @override
  StatsState build() {
    _fetchMonthlyStatsUseCase = ref.read(fetchMonthlyStatsUseCaseProvider);
    _fetchYearlyStatsUseCase = ref.read(fetchYearlyStatsUseCaseProvider);
    _fetchCategoryStatsUseCase =
        ref.read(fetchCategoryStatsUseCaseProvider);
    _fetchInsightsUseCase = ref.read(fetchInsightsUseCaseProvider);
    Future.microtask(() => loadAllStats());
    return StatsState(isLoading: true);
  }

  Future<void> loadAllStats() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final year = state.selectedYear;

    final results = await Future.wait([
      _fetchMonthlyStatsUseCase(year),
      _fetchYearlyStatsUseCase(),
      _fetchCategoryStatsUseCase(year),
      _fetchInsightsUseCase(year),
    ]);

    final monthlyResult = results[0] as Result<List<MonthlyStatsDto>>;
    final yearlyResult = results[1] as Result<List<YearlyStatsDto>>;
    final categoryResult = results[2] as Result<List<CategoryStatsDto>>;
    final insightsResult = results[3] as Result<ReadingInsightsDto>;

    AppError? firstError;

    final monthly = monthlyResult.when(
      success: (data) => data,
      failure: (error) {
        firstError ??= error;
        return state.monthlyStats;
      },
    );

    final yearly = yearlyResult.when(
      success: (data) => data,
      failure: (error) {
        firstError ??= error;
        return state.yearlyStats;
      },
    );

    final category = categoryResult.when(
      success: (data) => data,
      failure: (error) {
        firstError ??= error;
        return state.categoryStats;
      },
    );

    final insights = insightsResult.when(
      success: (data) => data,
      failure: (error) {
        firstError ??= error;
        return state.insights;
      },
    );

    state = state.copyWith(
      monthlyStats: monthly,
      yearlyStats: yearly,
      categoryStats: category,
      insights: insights,
      isLoading: false,
      error: firstError,
    );
  }

  Future<void> loadMonthlyStats() async {
    final result =
        await _fetchMonthlyStatsUseCase(state.selectedYear);
    result.when(
      success: (data) {
        state = state.copyWith(monthlyStats: data);
      },
      failure: (error) {
        state = state.copyWith(error: error);
      },
    );
  }

  Future<void> loadYearlyStats() async {
    final result = await _fetchYearlyStatsUseCase();
    result.when(
      success: (data) {
        state = state.copyWith(yearlyStats: data);
      },
      failure: (error) {
        state = state.copyWith(error: error);
      },
    );
  }

  Future<void> loadCategoryStats() async {
    final result =
        await _fetchCategoryStatsUseCase(state.selectedYear);
    result.when(
      success: (data) {
        state = state.copyWith(categoryStats: data);
      },
      failure: (error) {
        state = state.copyWith(error: error);
      },
    );
  }

  Future<void> loadInsights() async {
    final result = await _fetchInsightsUseCase(state.selectedYear);
    result.when(
      success: (data) {
        state = state.copyWith(insights: data);
      },
      failure: (error) {
        state = state.copyWith(error: error);
      },
    );
  }

  void setSelectedYear(int year) {
    state = state.copyWith(selectedYear: year);
    loadAllStats();
  }
}

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(() {
  return StatsNotifier();
});
