import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

/// 백엔드 서버를 통해 Google Cloud Vision API 호출
/// 서비스 계정은 백엔드에서 안전하게 관리
class GoogleVisionOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl; // 프로덕션 URL

  GoogleVisionOcrDataSource(this._dio) {
    print('📝 [OCR] Initialized Google Cloud Vision OCR via Backend (최고 정확도)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print(
      '📝 [OCR] Processing with Google Cloud Vision via Backend: $imagePath',
    );

    try {
      print('📝 [OCR] Sending request to backend server...');

      // 1. FormData 생성 (multipart/form-data)
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'engine': 'google', // Google Vision 엔진 지정
      });

      // 2. 백엔드 API 호출
      final response = await _dio.post('$_baseUrl/ocr/extract', data: formData);

      if (response.statusCode != 200) {
        print('❌ [OCR] Backend API error: ${response.statusCode}');
        print('❌ [OCR] Response: ${response.data}');
        throw Exception('Backend OCR API failed: ${response.statusCode}');
      }

      // 3. 응답 파싱 및 텍스트 정리
      final extractedText = (response.data['extractedText'] as String? ?? '')
          .replaceAll('\n', ' ') // 줄바꿈을 공백으로
          .replaceAll(RegExp(r'\s+'), ' ') // 연속된 공백을 하나로
          .trim(); // 앞뒤 공백 제거
      final confidence = response.data['confidence'] as int? ?? 0;

      print('📝 [OCR] Recognition complete');
      print('📊 [OCR] Confidence: $confidence%');
      print(
        '📝 [OCR] Extracted text length: ${extractedText.length} characters',
      );
      print('📝 [OCR] Extracted text:\n$extractedText');

      return extractedText;
    } catch (e) {
      print('❌ [OCR] ERROR: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Dio 인스턴스는 공유되므로 닫지 않음
    print('📝 [OCR] Google Cloud Vision OCR client disposed');
  }
}
