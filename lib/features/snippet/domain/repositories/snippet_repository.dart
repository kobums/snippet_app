import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_fetch_result.dart';

abstract class SnippetRepository {
  Future<Result<SnippetFetchResult>> fetchSnippets(int count);
  Future<Result<List<SnippetArchive>>> fetchArchive();
  Future<Result<void>> likeSnippet(int id);
  Future<Result<void>> unlikeSnippet(int id);
}
