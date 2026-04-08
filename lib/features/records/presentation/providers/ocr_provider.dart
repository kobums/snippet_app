import 'dart:ui' show Rect;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/domain/usecases/extract_text_from_image_usecase.dart';
import 'package:snippet_app/features/records/records_providers.dart';

class OcrState {
  final OcrResult? result;
  final List<OcrResult> results;
  final bool isProcessing;
  final AppError? error;
  final int currentIndex;
  final int totalCount;

  OcrState({
    this.result,
    this.results = const [],
    this.isProcessing = false,
    this.error,
    this.currentIndex = 0,
    this.totalCount = 0,
  });

  OcrState copyWith({
    OcrResult? result,
    List<OcrResult>? results,
    bool? isProcessing,
    AppError? error,
    int? currentIndex,
    int? totalCount,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return OcrState(
      result: clearResult ? null : (result ?? this.result),
      results: results ?? this.results,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
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

  /// 원본 이미지 1회 OCR + 밑줄 영역 필터링
  Future<void> processImageWithRegions(String imagePath, List<Rect> regions) async {
    state = OcrState(isProcessing: true);
    final result = await _extractTextUseCase(imagePath, regions: regions);
    result.when(
      success: (ocrResult) {
        state = OcrState(result: ocrResult, results: [ocrResult]);
      },
      failure: (error) {
        state = OcrState(error: error);
      },
    );
  }

  Future<void> processImage(String imagePath) async {
    state = OcrState(isProcessing: true);
    final result = await _extractTextUseCase(imagePath);
    result.when(
      success: (ocrResult) {
        state = OcrState(result: ocrResult, results: [ocrResult]);
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
