import 'package:dio/dio.dart';
import '../models/snippet.dart';
import '../models/snippet_archive.dart';
import 'dart:io' show Platform;

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          // Added user's custom production backend
          baseUrl: 'https://snippetapi.gowoobro.com/api',
          connectTimeout: const Duration(seconds: 5),
        ),
      ) {
    try {
      if (Platform.isAndroid && _dio.options.baseUrl.contains('localhost')) {
        _dio.options.baseUrl = 'http://10.0.2.2:8080/api';
      }
    } catch (e) {
      // Ignored for web
    }
  }

  Future<List<Snippet>> fetchSnippets(int count) async {
    try {
      final response = await _dio.get(
        '/snippets/cards',
        queryParameters: {'count': count},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Snippet.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API fetch error: $e');
      return [];
    }
  }

  Future<List<SnippetArchive>> fetchArchive(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final idsParam = ids.join(',');
      final response = await _dio.get(
        '/snippets/archive',
        queryParameters: {'ids': idsParam},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => SnippetArchive.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Archive API error: $e');
      return [];
    }
  }
}
