import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_fetch_result.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class FetchSnippetsUseCase {
  final SnippetRepository _repository;

  FetchSnippetsUseCase(this._repository);

  Future<Result<SnippetFetchResult>> call(int count) {
    return _repository.fetchSnippets(count);
  }
}
