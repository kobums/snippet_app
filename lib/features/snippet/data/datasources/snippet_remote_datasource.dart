import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_fetch_result.dart';

abstract class SnippetRemoteDataSource {
  Future<SnippetFetchResult> fetchSnippets(int count);
  Future<List<SnippetArchive>> fetchArchive();
  Future<void> addArchive(int snippetId);
  Future<void> removeArchive(int snippetId);
}

class SnippetRemoteDataSourceImpl implements SnippetRemoteDataSource {
  final Dio _dio;

  SnippetRemoteDataSourceImpl(this._dio);

  @override
  Future<SnippetFetchResult> fetchSnippets(int count) async {
    try {
      final response = await _dio.get(
        ApiConstants.snippetsCards,
        queryParameters: {'count': count},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List cards = data['cards'] ?? [];
        final int remainingToday = data['remainingToday'] ?? -1;
        return SnippetFetchResult(
          snippets: cards.map((e) => Snippet.fromJson(e)).toList(),
          remainingToday: remainingToday,
        );
      }
      return const SnippetFetchResult(snippets: [], remainingToday: -1);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<SnippetArchive>> fetchArchive() async {
    try {
      final response = await _dio.get(ApiConstants.snippetsArchive);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => SnippetArchive.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<void> addArchive(int snippetId) async {
    try {
      await _dio.post(
        ApiConstants.snippetsArchive,
        data: {'snippetId': snippetId},
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<void> removeArchive(int snippetId) async {
    try {
      await _dio.delete('${ApiConstants.snippetsArchive}/$snippetId');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
