import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class FetchArchiveUseCase {
  final SnippetRepository _repository;

  FetchArchiveUseCase(this._repository);

  Future<Result<List<SnippetArchive>>> call() {
    return _repository.fetchArchive();
  }
}
