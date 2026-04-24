import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';

class SessionHistoryState {
  final List<ReadingSessionDto> sessions;
  final bool isLoading;

  const SessionHistoryState({
    this.sessions = const [],
    this.isLoading = true,
  });

  SessionHistoryState copyWith({
    List<ReadingSessionDto>? sessions,
    bool? isLoading,
  }) {
    return SessionHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SessionHistoryNotifier extends AsyncNotifier<SessionHistoryState> {
  @override
  Future<SessionHistoryState> build() async {
    return _fetchSessions();
  }

  Future<SessionHistoryState> _fetchSessions() async {
    final useCase = ref.read(fetchAllSessionsUseCaseProvider);
    final result = await useCase();
    return switch (result) {
      Success(:final data) => SessionHistoryState(sessions: data, isLoading: false),
      Failure() => const SessionHistoryState(sessions: [], isLoading: false),
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSessions);
  }
}

final sessionHistoryProvider =
    AsyncNotifierProvider<SessionHistoryNotifier, SessionHistoryState>(() {
  return SessionHistoryNotifier();
});
