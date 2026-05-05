import 'package:snippet_app/features/snippet/data/models/snippet.dart';

class SnippetFetchResult {
  final List<Snippet> snippets;
  final int remainingToday; // -1 = 비로그인(무제한)

  const SnippetFetchResult({
    required this.snippets,
    required this.remainingToday,
  });
}
