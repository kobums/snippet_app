import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:snippet_app/core/config/ocr_config.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

class NaverClovaOcrDataSource implements OcrDataSource {
  final http.Client _httpClient;

  NaverClovaOcrDataSource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client() {
    print('📝 [OCR] Initialized Naver Clova OCR (한글 특화)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print('📝 [OCR] Processing with Naver Clova OCR: $imagePath');

    try {
      // 1. 이미지를 base64로 인코딩
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // 2. API 요청 준비
      final requestBody = {
        'version': 'V2',
        'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'images': [
          {
            'format': 'jpg',
            'name': 'snippet_image',
            'data': base64Image,
          }
        ]
      };

      print('📝 [OCR] Sending request to Naver Clova API...');

      // 3. API 호출
      final response = await _httpClient.post(
        Uri.parse(OcrConfig.naverClovaApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-OCR-SECRET': OcrConfig.naverClovaSecretKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print('❌ [OCR] Naver Clova API error: ${response.statusCode}');
        print('❌ [OCR] Response: ${response.body}');
        throw Exception('Naver Clova OCR API failed: ${response.statusCode}');
      }

      // 4. 응답 파싱
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final images = jsonResponse['images'] as List<dynamic>?;

      if (images == null || images.isEmpty) {
        print('⚠️ [OCR] No images in response');
        return '';
      }

      final fields = images[0]['fields'] as List<dynamic>?;
      if (fields == null || fields.isEmpty) {
        print('⚠️ [OCR] No text detected in image');
        return '';
      }

      // 5. 텍스트 추출 (각 필드의 inferText를 결합)
      final extractedLines = <String>[];
      for (final field in fields) {
        final inferText = field['inferText'] as String?;
        if (inferText != null && inferText.isNotEmpty) {
          extractedLines.add(inferText);
        }
      }

      final extractedText = extractedLines.join('\n');

      print('📝 [OCR] Recognition complete');
      print('📝 [OCR] Text blocks found: ${fields.length}');
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
    print('📝 [OCR] Naver Clova OCR client closed');
  }
}
