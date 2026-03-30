import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OCR API 설정
/// API 키는 .env 파일에서 관리됩니다.
/// .env 파일은 git에 커밋되지 않으므로 안전하게 관리할 수 있습니다.
class OcrConfig {
  // Naver Clova OCR 설정
  // https://www.ncloud.com/product/aiService/ocr 에서 발급
  static String get naverClovaApiUrl =>
      dotenv.env['NAVER_CLOVA_API_URL'] ?? '';
  static String get naverClovaSecretKey =>
      dotenv.env['NAVER_CLOVA_SECRET_KEY'] ?? '';

  // Google Cloud Vision API 설정
  // 백엔드 서버를 통해 호출하므로 앱에서는 설정 불필요
  // 서비스 계정은 백엔드에서 안전하게 관리됩니다

  // 기본 OCR 엔진 선택
  static OcrEngine defaultEngine = OcrEngine.mlKit;

  // API 키가 설정되어 있는지 확인
  static bool get isNaverClovaConfigured =>
      naverClovaApiUrl.isNotEmpty && naverClovaSecretKey.isNotEmpty;
  // Google Vision은 항상 사용 가능 (백엔드 서버 통함)
  static bool get isGoogleVisionConfigured => true;
}

enum OcrEngine {
  mlKit, // 무료, 오프라인, 온디바이스
  naverClova, // 한글 특화, API 키 필요, 온라인
  googleVision, // 최고 정확도, API 키 필요, 온라인
}
