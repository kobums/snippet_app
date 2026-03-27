import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrDataSource {
  Future<String> extractTextFromImage(String imagePath);
  void dispose();
}

class MlKitOcrDataSource implements OcrDataSource {
  late final TextRecognizer _textRecognizer;

  MlKitOcrDataSource() {
    // Korean script is optimized for Korean text (Hangul)
    // This provides better accuracy for Korean books
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    print('📝 [OCR] Initialized ML Kit with Korean script (한글 최적화)');
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    print('📝 [OCR] Processing image: $imagePath');

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      print('📝 [OCR] Image loaded, starting text recognition...');

      final recognizedText = await _textRecognizer.processImage(inputImage);

      print('📝 [OCR] Recognition complete');
      print('📝 [OCR] Text blocks found: ${recognizedText.blocks.length}');
      print('📝 [OCR] Extracted text length: ${recognizedText.text.length} characters');

      if (recognizedText.text.trim().isEmpty) {
        print('⚠️ [OCR] WARNING: No text detected in image');
        print('   - 이미지가 흐릿하거나 텍스트가 너무 작을 수 있습니다');
        print('   - 형광펜 영역을 더 크게 표시해보세요');
      } else {
        print('📝 [OCR] Extracted text:\n${recognizedText.text}');
      }

      return recognizedText.text;
    } catch (e) {
      print('❌ [OCR] ERROR: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    print('📝 [OCR] ML Kit text recognizer closed');
  }
}
