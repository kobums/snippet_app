import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:snippet_app/core/config/ocr_config.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

class GoogleVisionOcrDataSource implements OcrDataSource {
  final http.Client _httpClient;

  GoogleVisionOcrDataSource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client() {
    print('📝 [OCR] Initialized Google Cloud Vision OCR (최고 정확도)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print('📝 [OCR] Processing with Google Cloud Vision: $imagePath');

    try {
      // 1. 이미지를 base64로 인코딩
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // 2. API 요청 준비
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',  // 또는 DOCUMENT_TEXT_DETECTION
                'maxResults': 1,
              }
            ],
            // 한글 인식을 위한 언어 힌트
            'imageContext': {
              'languageHints': ['ko', 'en'],
            }
          }
        ]
      };

      print('📝 [OCR] Sending request to Google Cloud Vision API...');

      // 3. API 호출
      final response = await _httpClient.post(
        Uri.parse('${OcrConfig.googleCloudVisionApiUrl}?key=${OcrConfig.googleCloudVisionApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print('❌ [OCR] Google Vision API error: ${response.statusCode}');
        print('❌ [OCR] Response: ${response.body}');
        throw Exception('Google Cloud Vision API failed: ${response.statusCode}');
      }

      // 4. 응답 파싱
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = jsonResponse['responses'] as List<dynamic>?;

      if (responses == null || responses.isEmpty) {
        print('⚠️ [OCR] No responses from API');
        return '';
      }

      final textAnnotations = responses[0]['textAnnotations'] as List<dynamic>?;
      if (textAnnotations == null || textAnnotations.isEmpty) {
        print('⚠️ [OCR] No text detected in image');
        return '';
      }

      // 5. 텍스트 추출 (첫 번째 annotation이 전체 텍스트)
      final extractedText = textAnnotations[0]['description'] as String? ?? '';

      print('📝 [OCR] Recognition complete');
      print('📝 [OCR] Text annotations found: ${textAnnotations.length}');
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
    _httpClient.close();
    print('📝 [OCR] Google Cloud Vision OCR client closed');
  }
}
