import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/snippet.dart';
import '../models/snippet_archive.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final archiveProvider = FutureProvider<List<SnippetArchive>>((ref) async {
  final storage = ref.read(storageServiceProvider);
  final api = ref.read(apiServiceProvider);
  final ids = await storage.getLikedIds();
  if (ids.isEmpty) return [];
  return api.fetchArchive(ids);
});

class SnippetState {
  final List<Snippet> snippets;
  final bool isLoading;

  SnippetState({this.snippets = const [], this.isLoading = false});

  SnippetState copyWith({List<Snippet>? snippets, bool? isLoading}) {
    return SnippetState(
      snippets: snippets ?? this.snippets,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SnippetNotifier extends Notifier<SnippetState> {
  @override
  SnippetState build() {
    return SnippetState();
  }

  Future<void> fetchSnippets() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final newSnippets = await ref.read(apiServiceProvider).fetchSnippets(10);
    state = state.copyWith(
      snippets: [...state.snippets, ...newSnippets],
      isLoading: false,
    );
    _updateWidgetData();
  }

  Future<void> _updateWidgetData() async {
    if (state.snippets.isEmpty) return;
    try {
      await HomeWidget.setAppGroupId('group.com.gowoobro.snippet');
      final top = state.snippets.first;
      await HomeWidget.saveWidgetData<String>('snippet_text', top.text);
      await HomeWidget.saveWidgetData<String>('snippet_tag', top.tag);
      await HomeWidget.updateWidget(
        name: 'SnippetWidgetProvider',
        iOSName: 'snippetWidget',
      );
      print('Widget manually updated with text: ${top.text}');
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  void handleSwipe(int id, bool isLike) async {
    if (isLike) {
      await ref.read(storageServiceProvider).addLikedId(id);
      ref.invalidate(archiveProvider);
    }

    final updated = List<Snippet>.from(state.snippets)
      ..removeWhere((s) => s.id == id);
    state = state.copyWith(snippets: updated);
    _updateWidgetData();

    // Auto fetch more when low
    if (updated.length < 3) {
      fetchSnippets();
    }
  }
}

final snippetProvider = NotifierProvider<SnippetNotifier, SnippetState>(() {
  return SnippetNotifier();
});
