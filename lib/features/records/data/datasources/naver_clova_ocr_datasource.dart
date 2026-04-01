import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

class NaverClovaOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl;

  NaverClovaOcrDataSource(this._dio);

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileExists = await file.exists();

      if (!fileExists) {
        throw Exception('File does not exist: $imagePath');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'engine': 'naver',
      });

      final response = await _dio.post(
        '$_baseUrl/ocr/extract',
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend OCR API failed: ${response.statusCode}');
      }

      final extractedText = (response.data['extractedText'] as String? ?? '');

      return extractedText;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
  }
}
