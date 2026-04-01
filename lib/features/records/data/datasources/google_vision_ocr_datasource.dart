import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

class GoogleVisionOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl;

  GoogleVisionOcrDataSource(this._dio);

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'engine': 'google',
      });

      final response = await _dio.post('$_baseUrl/ocr/extract', data: formData);

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
