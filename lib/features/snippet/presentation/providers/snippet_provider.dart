import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/domain/usecases/fetch_snippets_usecase.dart';
import 'package:snippet_app/features/snippet/domain/usecases/handle_swipe_usecase.dart';
import 'package:snippet_app/features/snippet/domain/usecases/update_widget_usecase.dart';
import 'package:snippet_app/features/snippet/snippet_providers.dart';

class SnippetState {
  final List<Snippet> snippets;
  final bool isLoading;
  final AppError? error;

  SnippetState({
    this.snippets = const [],
    this.isLoading = false,
    this.error,
  });

  SnippetState copyWith({
    List<Snippet>? snippets,
    bool? isLoading,
    AppError? error,
  }) {
    return SnippetState(
      snippets: snippets ?? this.snippets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SnippetNotifier extends Notifier<SnippetState> {
  late final FetchSnippetsUseCase _fetchSnippetsUseCase;
  late final HandleSwipeUseCase _handleSwipeUseCase;
  late final UpdateWidgetUseCase _updateWidgetUseCase;

  @override
  SnippetState build() {
    _fetchSnippetsUseCase = ref.read(fetchSnippetsUseCaseProvider);
    _handleSwipeUseCase = ref.read(handleSwipeUseCaseProvider);
    _updateWidgetUseCase = ref.read(updateWidgetUseCaseProvider);
    return SnippetState();
  }

  Future<void> fetchSnippets() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final result =
        await _fetchSnippetsUseCase(AppConstants.snippetFetchCount);
    result.when(
      success: (newSnippets) {
        state = state.copyWith(
          snippets: [...state.snippets, ...newSnippets],
          isLoading: false,
        );
        _updateWidgetUseCase(state.snippets);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );
  }

  void handleSwipe(int id, bool isLike) async {
    // 1. Optimistic Update - 먼저 UI에서 카드 제거
    final removed = state.snippets.firstWhere((s) => s.id == id);
    final updated = List<Snippet>.from(state.snippets)
      ..removeWhere((s) => s.id == id);
    state = state.copyWith(snippets: updated);
    _updateWidgetUseCase(updated);

    // 2. 백그라운드에서 API 호출
    final result = await _handleSwipeUseCase(id, isLike);

    // 3. 결과 처리
    result.when(
      success: (_) {
        if (isLike) {
          ref.invalidate(archiveProvider);
        }
        if (updated.length < AppConstants.snippetLowThreshold) {
          fetchSnippets();
        }
      },
      failure: (error) {
        // 실패 시 롤백 - 카드 다시 맨 앞에 추가
        final rollback = [removed, ...state.snippets];
        state = state.copyWith(snippets: rollback, error: error);
        _updateWidgetUseCase(rollback);
      },
    );
  }
}

final snippetProvider = NotifierProvider<SnippetNotifier, SnippetState>(() {
  return SnippetNotifier();
});

final archiveProvider = FutureProvider<List<SnippetArchive>>((ref) async {
  final fetchArchive = ref.read(fetchArchiveUseCaseProvider);
  final result = await fetchArchive();
  return result.when(
    success: (data) => data,
    failure: (_) => [],
  );
});
