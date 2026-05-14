import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/dashboard/data/datasources/calendar_share_datasource.dart';
import 'package:snippet_app/features/dashboard/data/datasources/stats_remote_datasource.dart';
import 'package:snippet_app/features/dashboard/data/models/reading_goal.dart';
import 'package:snippet_app/features/dashboard/data/repositories/stats_repository_impl.dart';
import 'package:snippet_app/features/dashboard/domain/repositories/stats_repository.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_category_stats_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_insights_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_monthly_stats_usecase.dart';
import 'package:snippet_app/features/dashboard/domain/usecases/fetch_yearly_stats_usecase.dart';

// DataSources
final statsRemoteDataSourceProvider =
    Provider<StatsRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return StatsRemoteDataSourceImpl(dio);
});

final calendarShareServiceProvider = Provider<CalendarShareService>((ref) {
  return CalendarShareService();
});

// Repository
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final remote = ref.read(statsRemoteDataSourceProvider);
  return StatsRepositoryImpl(remote);
});

// UseCases
final fetchMonthlyStatsUseCaseProvider =
    Provider<FetchMonthlyStatsUseCase>((ref) {
  return FetchMonthlyStatsUseCase(ref.read(statsRepositoryProvider));
});

final fetchYearlyStatsUseCaseProvider =
    Provider<FetchYearlyStatsUseCase>((ref) {
  return FetchYearlyStatsUseCase(ref.read(statsRepositoryProvider));
});

final fetchCategoryStatsUseCaseProvider =
    Provider<FetchCategoryStatsUseCase>((ref) {
  return FetchCategoryStatsUseCase(ref.read(statsRepositoryProvider));
});

final fetchInsightsUseCaseProvider = Provider<FetchInsightsUseCase>((ref) {
  return FetchInsightsUseCase(ref.read(statsRepositoryProvider));
});

// Reading Goal
class ReadingGoalNotifier extends AsyncNotifier<ReadingGoalDto> {
  @override
  Future<ReadingGoalDto> build() async {
    return _fetch(DateTime.now().year);
  }

  Future<ReadingGoalDto> _fetch(int year) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get(
        ApiConstants.readingGoals,
        queryParameters: {'year': year},
      );
      return ReadingGoalDto.fromJson(response.data);
    } catch (_) {
      return ReadingGoalDto.empty();
    }
  }

  Future<void> setGoal(int targetBooks) async {
    final current = state.valueOrNull ?? ReadingGoalDto.empty();
    state = const AsyncLoading();
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.put(
        ApiConstants.readingGoals,
        data: {'year': current.year, 'targetBooks': targetBooks},
      );
      state = AsyncData(ReadingGoalDto.fromJson(response.data));
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final readingGoalProvider =
    AsyncNotifierProvider<ReadingGoalNotifier, ReadingGoalDto>(
  ReadingGoalNotifier.new,
);
