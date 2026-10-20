/// OCR API 설정
///
/// OCR은 엔진과 무관하게 전부 백엔드(`POST /api/ocr/extract`)를 통해 호출한다.
/// 키(Google Vision 서비스 계정, Naver Clova 시크릿)는 서버에만 있다.
/// 예전의 Naver Clova 앱 직접 호출은 시크릿 키를 앱 번들(.env 에셋)에 넣어야 해서
/// APK/IPA에서 키가 추출되는 문제가 있어 백엔드 경유로 바꿨다.
class OcrConfig {
  static OcrEngine defaultEngine = OcrEngine.googleVision;

  // 키는 서버에서 관리하므로 앱에서는 항상 사용 가능으로 본다.
  static bool get isNaverClovaConfigured => true;
  static bool get isGoogleVisionConfigured => true;
}

enum OcrEngine {
  naverClova, // 한글 특화, 온라인 (백엔드 engine=naver)
  googleVision, // 최고 정확도, 온라인 (백엔드 engine=google)
}
