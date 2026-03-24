import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';

abstract class SnippetRepository {
  Future<Result<List<Snippet>>> fetchSnippets(int count);
  Future<Result<List<SnippetArchive>>> fetchArchive();
  Future<Result<void>> likeSnippet(int id);
  Future<Result<void>> unlikeSnippet(int id);
}
