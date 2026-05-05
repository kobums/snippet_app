import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/snippet/data/datasources/snippet_remote_datasource.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_fetch_result.dart';
import 'package:snippet_app/features/snippet/domain/repositories/snippet_repository.dart';

class SnippetRepositoryImpl implements SnippetRepository {
  final SnippetRemoteDataSource _remoteDataSource;

  SnippetRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<SnippetFetchResult>> fetchSnippets(int count) async {
    try {
      final result = await _remoteDataSource.fetchSnippets(count);
      return Success(result);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<List<SnippetArchive>>> fetchArchive() async {
    try {
      final archive = await _remoteDataSource.fetchArchive();
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
      await _remoteDataSource.addArchive(id);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> unlikeSnippet(int id) async {
    try {
      await _remoteDataSource.removeArchive(id);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
