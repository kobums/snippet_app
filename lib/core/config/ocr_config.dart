/// OCR API 설정
///
/// OCR은 전부 백엔드(`POST /api/ocr/extract`, Google Cloud Vision)를 통해 호출한다.
/// 예전의 Naver Clova 직접 호출은 시크릿 키를 앱 번들(.env 에셋)에 넣어야 해서
/// APK/IPA에서 키가 추출되는 문제가 있어 제거했다.
class OcrConfig {
  static OcrEngine defaultEngine = OcrEngine.googleVision;

  static bool get isGoogleVisionConfigured => true;
}

enum OcrEngine {
  googleVision, // 최고 정확도, 온라인 (백엔드 경유)
}
