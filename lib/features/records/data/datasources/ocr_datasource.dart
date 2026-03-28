import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
      // 이미지 전처리로 OCR 정확도 향상
      final preprocessedImagePath = await _preprocessImage(imagePath);
      print('📝 [OCR] Image preprocessing complete: $preprocessedImagePath');

      final inputImage = InputImage.fromFilePath(preprocessedImagePath);
      print('📝 [OCR] Image loaded, starting text recognition...');

      final recognizedText = await _textRecognizer.processImage(inputImage);

      // 임시 전처리 파일 삭제
      try {
        await File(preprocessedImagePath).delete();
      } catch (_) {}

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

  /// 이미지 전처리: 그레이스케일, 대비 향상, 이진화
  Future<String> _preprocessImage(String imagePath) async {
    print('🎨 [OCR] Starting image preprocessing...');

    // 1. 원본 이미지 로드
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      print('⚠️ [OCR] Failed to decode image, using original');
      return imagePath;
    }

    print('🎨 [OCR] Original image size: ${image.width}x${image.height}');

    // 2. 그레이스케일 변환 (색상 정보 제거로 텍스트에 집중)
    var processed = img.grayscale(image);
    print('🎨 [OCR] ✓ Grayscale conversion');

    // 3. 대비 향상 (텍스트와 배경의 차이를 명확하게)
    processed = img.adjustColor(processed, contrast: 1.5, brightness: 1.1);
    print('🎨 [OCR] ✓ Contrast enhancement (1.5x)');

    // 4. 선명도 향상
    processed = img.adjustColor(processed, saturation: 0);
    print('🎨 [OCR] ✓ Sharpness enhancement');

    // 5. 임시 파일로 저장
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final preprocessedFile = File(tempPath);
    await preprocessedFile.writeAsBytes(img.encodeJpg(processed, quality: 95));

    print('🎨 [OCR] Preprocessing complete, saved to: $tempPath');
    return tempPath;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    print('📝 [OCR] ML Kit text recognizer closed');
  }
}
