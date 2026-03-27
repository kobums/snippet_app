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
