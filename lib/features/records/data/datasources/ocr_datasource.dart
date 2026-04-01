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
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
  }

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final preprocessedImagePath = await _preprocessImage(imagePath);

      final inputImage = InputImage.fromFilePath(preprocessedImagePath);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      try {
        await File(preprocessedImagePath).delete();
      } catch (_) {}

      return recognizedText.text;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _preprocessImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return imagePath;
    }

    var processed = img.grayscale(image);

    processed = img.adjustColor(processed, contrast: 1.5, brightness: 1.1);

    processed = img.adjustColor(processed, saturation: 0);

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/preprocessed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final preprocessedFile = File(tempPath);
    await preprocessedFile.writeAsBytes(img.encodeJpg(processed, quality: 95));

    return tempPath;
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}
