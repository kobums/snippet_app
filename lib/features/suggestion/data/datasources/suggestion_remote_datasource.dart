import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';

abstract class SuggestionRemoteDataSource {
  Future<SuggestionDto> submit(SuggestionAddRequestDto data);
}

class SuggestionRemoteDataSourceImpl implements SuggestionRemoteDataSource {
  final Dio _dio;

  SuggestionRemoteDataSourceImpl(this._dio);

  @override
  Future<SuggestionDto> submit(SuggestionAddRequestDto data) async {
    try {
      final response = await _dio.post(
        ApiConstants.suggestions,
        data: data.toJson(),
      );
      return SuggestionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
