import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_local_datasource.dart';
import 'package:snippet_app/features/reading_session/data/datasources/reading_session_remote_datasource.dart';
import 'package:snippet_app/features/reading_session/data/repositories/reading_session_repository_impl.dart';
import 'package:snippet_app/features/reading_session/domain/repositories/reading_session_repository.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/save_reading_session_usecase.dart';
import 'package:snippet_app/features/reading_session/domain/usecases/fetch_sessions_by_book_usecase.dart';

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
