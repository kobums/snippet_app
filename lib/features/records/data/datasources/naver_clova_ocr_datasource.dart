import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

/// 백엔드 서버를 통해 Naver Clova OCR API 호출
/// API 키는 백엔드에서 안전하게 관리
class NaverClovaOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl; // 프로덕션 URL

  NaverClovaOcrDataSource(this._dio) {
    print('📝 [OCR] Initialized Naver Clova OCR via Backend (한글 특화)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print('📝 [OCR] Processing with Naver Clova via Backend: $imagePath');

    try {
      // 1. 파일 존재 확인
      final file = File(imagePath);
      final fileExists = await file.exists();
      print('📝 [OCR] File exists: $fileExists');

      if (!fileExists) {
        throw Exception('File does not exist: $imagePath');
      }

      final fileSize = await file.length();
      print('📝 [OCR] File size: $fileSize bytes (${fileSize ~/ 1024} KB)');

      print('📝 [OCR] Creating FormData...');

      // 2. FormData 생성 (multipart/form-data)
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'engine': 'naver', // Naver Clova 엔진 지정
      });

      print('📝 [OCR] Sending request to backend server...');
      print('📝 [OCR] URL: $_baseUrl/api/ocr/extract');

      // 3. 백엔드 API 호출
      final response = await _dio.post(
        '$_baseUrl/ocr/extract',
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        print('❌ [OCR] Backend API error: ${response.statusCode}');
        print('❌ [OCR] Response: ${response.data}');
        throw Exception('Backend OCR API failed: ${response.statusCode}');
      }

      // 4. 응답 파싱 및 텍스트 정리
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
    print('📝 [OCR] Naver Clova OCR client disposed');
  }
}
