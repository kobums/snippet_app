import 'dart:ui' show Rect;

abstract class OcrDataSource {
  /// 전체 이미지 텍스트 추출
  Future<String> extractTextFromImage(String imagePath);

  /// 전체 이미지 1회 OCR 후 [regions] 영역(이미지 픽셀 좌표)에 속하는 텍스트만 반환
  Future<String> extractTextFromRegions(String imagePath, List<Rect> regions);

  void dispose();
}
