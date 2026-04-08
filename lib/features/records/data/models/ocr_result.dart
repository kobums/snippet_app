import 'dart:ui' show Rect;

class OcrResult {
  final String extractedText;
  final String imagePath;
  final DateTime timestamp;

  OcrResult({
    required this.extractedText,
    required this.imagePath,
    required this.timestamp,
  });

  OcrResult copyWith({
    String? extractedText,
    String? imagePath,
    DateTime? timestamp,
  }) {
    return OcrResult(
      extractedText: extractedText ?? this.extractedText,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// ImageHighlighterScreen → OcrResultScreen 간 라우팅 파라미터
/// [imagePath]: 원본 이미지 경로
/// [regions]: 밑줄 영역 (이미지 픽셀 좌표 기준 Rect 리스트)
class OcrRequest {
  final String imagePath;
  final List<Rect> regions;

  const OcrRequest({required this.imagePath, required this.regions});
}
