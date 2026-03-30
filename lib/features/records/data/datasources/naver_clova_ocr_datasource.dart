import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

/// 백엔드 서버를 통해 Naver Clova OCR API 호출
/// API 키는 백엔드에서 안전하게 관리
class NaverClovaOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://snippet.gowoobro.com'; // 프로덕션 URL

  NaverClovaOcrDataSource(this._dio) {
    print('📝 [OCR] Initialized Naver Clova OCR via Backend (한글 특화)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print('📝 [OCR] Processing with Naver Clova via Backend: $imagePath');

    try {
      // 1. 이미지를 base64로 인코딩
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      print('📝 [OCR] Sending request to backend server...');

      // 2. 백엔드 API 호출 (Naver 엔진 지정)
      final response = await _dio.post(
        '$_baseUrl/api/ocr/extract',
        data: {
          'imageBase64': base64Image,
          'engine': 'naver', // Naver Clova 엔진 지정
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        print('❌ [OCR] Backend API error: ${response.statusCode}');
        print('❌ [OCR] Response: ${response.data}');
        throw Exception('Backend OCR API failed: ${response.statusCode}');
      }

      // 3. 응답 파싱
      final extractedText = response.data['extractedText'] as String? ?? '';
      final confidence = response.data['confidence'] as int? ?? 0;

      print('📝 [OCR] Recognition complete');
      print('📊 [OCR] Confidence: $confidence%');
      print('📝 [OCR] Extracted text length: ${extractedText.length} characters');
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
    print('📝 [OCR] Naver Clova OCR client disposed');
  }
}
