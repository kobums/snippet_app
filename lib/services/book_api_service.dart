import 'package:dio/dio.dart';
import '../models/book_search.dart';

class BookApiService {
  final Dio _dio;

  BookApiService(this._dio);

  Future<List<BookSearchDto>> searchBooks(String query, int page) async {
    try {
      final response = await _dio.get(
        '/books/search',
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
      print('Book search error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to search books. Please try again.',
      );
    }
  }
}
