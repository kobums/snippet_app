import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OCR API 설정
class OcrConfig {
  // Naver Clova OCR 설정
  static String get naverClovaApiUrl =>
      dotenv.env['NAVER_CLOVA_API_URL'] ?? '';
  static String get naverClovaSecretKey =>
      dotenv.env['NAVER_CLOVA_SECRET_KEY'] ?? '';

  // Google Cloud Vision은 백엔드 서버를 통해 호출 (앱에서 설정 불필요)

  static OcrEngine defaultEngine = OcrEngine.googleVision;

  static bool get isNaverClovaConfigured =>
      naverClovaApiUrl.isNotEmpty && naverClovaSecretKey.isNotEmpty;
  static bool get isGoogleVisionConfigured => true;
}

enum OcrEngine {
  naverClova, // 한글 특화, 온라인
  googleVision, // 최고 정확도, 온라인
}
