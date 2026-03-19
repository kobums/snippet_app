import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/snippet/data/datasources/snippet_local_datasource.dart';
import 'package:snippet_app/features/snippet/data/datasources/snippet_remote_datasource.dart';
import 'package:snippet_app/features/snippet/data/repositories/snippet_repository_impl.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';
import 'package:snippet_app/features/snippet/domain/usecases/fetch_archive_usecase.dart';
import 'package:snippet_app/features/snippet/domain/usecases/fetch_snippets_usecase.dart';
import 'package:snippet_app/features/snippet/domain/usecases/handle_swipe_usecase.dart';
import 'package:snippet_app/features/snippet/domain/usecases/update_widget_usecase.dart';

// DataSources
final snippetRemoteDataSourceProvider =
    Provider<SnippetRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return SnippetRemoteDataSourceImpl(dio);
});

final snippetLocalDataSourceProvider =
    Provider<SnippetLocalDataSource>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SnippetLocalDataSourceImpl(prefs);
});

// Repository
final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  final remote = ref.read(snippetRemoteDataSourceProvider);
  final local = ref.read(snippetLocalDataSourceProvider);
  return SnippetRepositoryImpl(remote, local);
});

// UseCases
final fetchSnippetsUseCaseProvider = Provider<FetchSnippetsUseCase>((ref) {
  return FetchSnippetsUseCase(ref.read(snippetRepositoryProvider));
});

final fetchArchiveUseCaseProvider = Provider<FetchArchiveUseCase>((ref) {
  return FetchArchiveUseCase(ref.read(snippetRepositoryProvider));
});

final handleSwipeUseCaseProvider = Provider<HandleSwipeUseCase>((ref) {
  return HandleSwipeUseCase(ref.read(snippetRepositoryProvider));
});

final updateWidgetUseCaseProvider = Provider<UpdateWidgetUseCase>((ref) {
  return UpdateWidgetUseCase();
});
