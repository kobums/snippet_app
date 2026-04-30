import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';
import 'package:snippet_app/features/suggestion/suggestion_providers.dart';

class SuggestionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SuggestionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SuggestionState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) =>
      SuggestionState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class SuggestionNotifier extends Notifier<SuggestionState> {
  @override
  SuggestionState build() => const SuggestionState();

  Future<void> submit(SuggestionAddRequestDto data) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await ref.read(submitSuggestionUseCaseProvider)(data);
    result.when(
      success: (_) => state = state.copyWith(isLoading: false, isSuccess: true),
      failure: (e) => state = state.copyWith(isLoading: false, error: e.message),
    );
  }

  void reset() => state = const SuggestionState();
}

final suggestionProvider =
    NotifierProvider<SuggestionNotifier, SuggestionState>(() {
  return SuggestionNotifier();
});
