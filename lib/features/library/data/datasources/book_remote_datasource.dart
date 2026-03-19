import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';

abstract class BookRemoteDataSource {
  Future<List<BookSearchDto>> searchBooks(String query, int page);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final Dio _dio;

  BookRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BookSearchDto>> searchBooks(String query, int page) async {
    try {
      final response = await _dio.get(
        ApiConstants.booksSearch,
        queryParameters: {
          'query': query,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => BookSearchDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
