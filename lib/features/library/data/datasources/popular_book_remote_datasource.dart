import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';

abstract class PopularBookRemoteDataSource {
  Future<List<PopularBookDto>> getPopularBooks({
    String startDt,
    String endDt,
    String kdc,
    String dtlKdc,
    String age,
    String gender,
    String region,
    String dtlRegion,
    int pageNo,
    int pageSize,
  });
}

class PopularBookRemoteDataSourceImpl implements PopularBookRemoteDataSource {
  final Dio _dio;

  PopularBookRemoteDataSourceImpl(this._dio);

  @override
  Future<List<PopularBookDto>> getPopularBooks({
    String startDt = '',
    String endDt = '',
    String kdc = '',
    String dtlKdc = '',
    String age = '',
    String gender = '',
    String region = '',
    String dtlRegion = '',
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.booksPopular,
        queryParameters: {
          if (startDt.isNotEmpty) 'startDt': startDt,
          if (endDt.isNotEmpty) 'endDt': endDt,
          if (kdc.isNotEmpty) 'kdc': kdc,
          if (dtlKdc.isNotEmpty) 'dtlKdc': dtlKdc,
          if (age.isNotEmpty) 'age': age,
          if (gender.isNotEmpty) 'gender': gender,
          if (region.isNotEmpty) 'region': region,
          if (dtlRegion.isNotEmpty) 'dtlRegion': dtlRegion,
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => PopularBookDto.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
