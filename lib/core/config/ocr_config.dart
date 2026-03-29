/// OCR API 설정
class OcrConfig {
  // Naver Clova OCR 설정
  // https://www.ncloud.com/product/aiService/ocr 에서 발급
  static const String naverClovaApiUrl = 'https://lc6ezulaq7.apigw.ntruss.com/custom/v1/34188/c2f2d8a3fab30e2597d8c0d47aadad2f8e8be4b5fe01e64c7ecdec49bd913ad9/general';
  static const String naverClovaSecretKey = 'YOUR_NAVER_CLOVA_SECRET_KEY';

  // Google Cloud Vision API 설정
  // https://cloud.google.com/vision/docs/setup 에서 발급
  static const String googleCloudVisionApiKey = 'YOUR_GOOGLE_CLOUD_VISION_API_KEY';
  static const String googleCloudVisionApiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  // 기본 OCR 엔진 선택
  static OcrEngine defaultEngine = OcrEngine.mlKit;
}

enum OcrEngine {
  mlKit,        // 무료, 오프라인, 온디바이스
  naverClova,   // 한글 특화, API 키 필요, 온라인
  googleVision, // 최고 정확도, API 키 필요, 온라인
}
