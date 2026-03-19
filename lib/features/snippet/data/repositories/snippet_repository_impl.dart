import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/datasources/snippet_local_datasource.dart';
import 'package:snippet_app/features/snippet/data/datasources/snippet_remote_datasource.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class SnippetRepositoryImpl implements SnippetRepository {
  final SnippetRemoteDataSource _remoteDataSource;
  final SnippetLocalDataSource _localDataSource;

  SnippetRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<List<Snippet>>> fetchSnippets(int count) async {
    try {
      final snippets = await _remoteDataSource.fetchSnippets(count);
      return Success(snippets);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<SnippetArchive>>> fetchArchive() async {
    try {
      final ids = await _localDataSource.getLikedIds();
      if (ids.isEmpty) return const Success([]);
      final archive = await _remoteDataSource.fetchArchive(ids);
      return Success(archive);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> likeSnippet(int id) async {
    try {
      await _localDataSource.addLikedId(id);
      return const Success(null);
    } catch (e) {
      return const Failure(CacheError('스니펫 저장에 실패했습니다'));
    }
  }
}
