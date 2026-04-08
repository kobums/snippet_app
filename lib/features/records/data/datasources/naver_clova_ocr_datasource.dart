import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;
import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/records/data/datasources/ocr_datasource.dart';

class NaverClovaOcrDataSource implements OcrDataSource {
  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl;

  NaverClovaOcrDataSource(this._dio);

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    return _callBackend(imagePath, regions: null);
  }

  @override
  Future<String> extractTextFromRegions(String imagePath, List<Rect> regions) async {
    return _callBackend(imagePath, regions: regions);
  }

  Future<String> _callBackend(String imagePath, {List<Rect>? regions}) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $imagePath');
    }

    final Map<String, dynamic> fields = {
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
      'engine': 'naver',
    };

    if (regions != null && regions.isNotEmpty) {
      fields['regions'] = jsonEncode(regions
          .map((r) => {'left': r.left, 'top': r.top, 'right': r.right, 'bottom': r.bottom})
          .toList());
    }

    final response = await _dio.post(
      '$_baseUrl/ocr/extract',
      data: FormData.fromMap(fields),
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend OCR API failed: ${response.statusCode}');
    }
    return response.data['extractedText'] as String? ?? '';
  }

  @override
  void dispose() {}
}
