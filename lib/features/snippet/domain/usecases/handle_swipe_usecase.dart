import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class HandleSwipeUseCase {
  final SnippetRepository _repository;

  HandleSwipeUseCase(this._repository);

  Future<Result<void>> call(int id, bool isLike) async {
    if (isLike) {
      return _repository.likeSnippet(id);
    }
    return _repository.skipSnippet(id);
  }
}
