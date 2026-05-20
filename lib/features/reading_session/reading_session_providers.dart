import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_local_datasource.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_remote_datasource.dart';
import 'package:snippet_app/features/reading_session/data/repositories/reading_session_repository_impl.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/streak.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/save_reading_session_usecase.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/fetch_sessions_by_book_usecase.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/fetch_all_sessions_usecase.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/fetch_streak_usecase.dart';

// DataSources
final readingSessionRemoteDataSourceProvider =
    Provider<ReadingSessionRemoteDataSource>((ref) {
  return ReadingSessionRemoteDataSourceImpl(ref.read(dioProvider));
});

final readingSessionLocalDataSourceProvider =
    Provider<ReadingSessionLocalDataSource>((ref) {
  return ReadingSessionLocalDataSourceImpl(ref.read(sharedPreferencesProvider));
});

// Repository
final readingSessionRepositoryProvider =
    Provider<ReadingSessionRepository>((ref) {
  return ReadingSessionRepositoryImpl(
    ref.read(readingSessionRemoteDataSourceProvider),
  );
});

// UseCases
final saveReadingSessionUseCaseProvider =
    Provider<SaveReadingSessionUseCase>((ref) {
  return SaveReadingSessionUseCase(ref.read(readingSessionRepositoryProvider));
});

final fetchSessionsByBookUseCaseProvider =
    Provider<FetchSessionsByBookUseCase>((ref) {
  return FetchSessionsByBookUseCase(ref.read(readingSessionRepositoryProvider));
});

final fetchAllSessionsUseCaseProvider =
    Provider<FetchAllSessionsUseCase>((ref) {
  return FetchAllSessionsUseCase(ref.read(readingSessionRepositoryProvider));
});

final fetchStreakUseCaseProvider = Provider<FetchStreakUseCase>((ref) {
  return FetchStreakUseCase(ref.read(readingSessionRepositoryProvider));
});

final streakProvider = FutureProvider<StreakDto>((ref) async {
  final useCase = ref.read(fetchStreakUseCaseProvider);
  final result = await useCase();
  return result.when(
    success: (streak) => streak,
    failure: (_) => StreakDto.empty(),
  );
});

// Signals book_detail_screen to switch to the session tab after a session completes.
class SessionCompletedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void signal() => state = true;
  void reset()  => state = false;
}

final sessionJustCompletedProvider =
    NotifierProvider<SessionCompletedNotifier, bool>(SessionCompletedNotifier.new);
