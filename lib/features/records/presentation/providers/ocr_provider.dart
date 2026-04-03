import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/domain/usecases/extract_text_from_image_usecase.dart';
import 'package:snippet_app/features/records/records_providers.dart';

class OcrState {
  final OcrResult? result; // 단일 결과 (하위 호환성)
  final List<OcrResult> results; // 다중 결과
  final bool isProcessing;
  final AppError? error;
  final int currentIndex; // 현재 처리 중인 인덱스
  final int totalCount; // 전체 개수

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

  /// 여러 이미지를 순차적으로 처리
  Future<void> processMultipleImages(List<String> imagePaths) async {
    state = OcrState(
      isProcessing: true,
      totalCount: imagePaths.length,
    );

    final results = <OcrResult>[];

    for (int i = 0; i < imagePaths.length; i++) {
      state = state.copyWith(
        currentIndex: i,
        isProcessing: true,
      );

      final result = await _extractTextUseCase(imagePaths[i]);
      result.when(
        success: (ocrResult) {
          results.add(ocrResult);
        },
        failure: (error) {
          // 실패해도 빈 결과로 추가 (인덱스 유지)
          results.add(OcrResult(
            extractedText: '',
            imagePath: imagePaths[i],
            timestamp: DateTime.now(),
          ));
        },
      );
    }

    state = OcrState(
      results: results,
      isProcessing: false,
      totalCount: imagePaths.length,
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
