import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class FetchSnippetsUseCase {
  final SnippetRepository _repository;

  FetchSnippetsUseCase(this._repository);

  Future<Result<List<Snippet>>> call(int count) {
    return _repository.fetchSnippets(count);
  }
}
