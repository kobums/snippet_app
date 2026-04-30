import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/suggestion/data/datasources/suggestion_remote_datasource.dart';
import 'package:snippet_app/features/suggestion/data/repositories/suggestion_repository_impl.dart';
import 'package:snippet_app/features/suggestion/domain/repositories/suggestion_repository.dart';
import 'package:snippet_app/features/suggestion/domain/usecases/submit_suggestion_usecase.dart';

final suggestionRemoteDataSourceProvider =
    Provider<SuggestionRemoteDataSource>((ref) {
  return SuggestionRemoteDataSourceImpl(ref.read(dioProvider));
});

final suggestionRepositoryProvider = Provider<SuggestionRepository>((ref) {
  return SuggestionRepositoryImpl(ref.read(suggestionRemoteDataSourceProvider));
});

final submitSuggestionUseCaseProvider = Provider<SubmitSuggestionUseCase>((ref) {
  return SubmitSuggestionUseCase(ref.read(suggestionRepositoryProvider));
});
