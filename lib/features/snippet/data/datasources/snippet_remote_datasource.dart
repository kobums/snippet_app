import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/snippet/data/models/snippet.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';

abstract class SnippetRemoteDataSource {
  Future<List<Snippet>> fetchSnippets(int count);
  Future<List<SnippetArchive>> fetchArchive(List<int> ids);
}

class SnippetRemoteDataSourceImpl implements SnippetRemoteDataSource {
  final Dio _dio;

  SnippetRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Snippet>> fetchSnippets(int count) async {
    try {
      final response = await _dio.get(
        ApiConstants.snippetsCards,
        queryParameters: {'count': count},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Snippet.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<List<SnippetArchive>> fetchArchive(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final idsParam = ids.join(',');
      final response = await _dio.get(
        ApiConstants.snippetsArchive,
        queryParameters: {'ids': idsParam},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => SnippetArchive.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
