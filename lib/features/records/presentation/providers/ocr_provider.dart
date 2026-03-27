import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/domain/usecases/extract_text_from_image_usecase.dart';
import 'package:snippet_app/features/records/records_providers.dart';

class OcrState {
  final OcrResult? result;
  final bool isProcessing;
  final AppError? error;

  OcrState({
    this.result,
    this.isProcessing = false,
    this.error,
  });

  OcrState copyWith({
    OcrResult? result,
    bool? isProcessing,
    AppError? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return OcrState(
      result: clearResult ? null : (result ?? this.result),
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OcrNotifier extends Notifier<OcrState> {
  late final ExtractTextFromImageUseCase _extractTextUseCase;

  @override
  OcrState build() {
    _extractTextUseCase = ref.read(extractTextFromImageUseCaseProvider);
    return OcrState();
  }

  Future<void> processImage(String imagePath) async {
    state = OcrState(isProcessing: true);

    final result = await _extractTextUseCase(imagePath);
    result.when(
      success: (ocrResult) {
        state = OcrState(result: ocrResult);
      },
      failure: (error) {
        state = OcrState(error: error);
      },
    );
  }

  void reset() {
    state = OcrState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final ocrProvider = NotifierProvider<OcrNotifier, OcrState>(() {
  return OcrNotifier();
});
