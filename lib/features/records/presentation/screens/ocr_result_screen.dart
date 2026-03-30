import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/presentation/providers/ocr_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

class OcrResultScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const OcrResultScreen({super.key, required this.imagePath});

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  final _textController = TextEditingController();
  bool _hasProcessed = false;

  @override
  void initState() {
    super.initState();

    // OCR 처리 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(ocrProvider.notifier).processImage(widget.imagePath);
      }
    });

    // OCR 결과를 감지하여 텍스트 필드에 채우기
    ref.listenManual(
      ocrProvider,
      (previous, next) {
        if (mounted && next.result != null && !_hasProcessed) {
          _textController.text = next.result!.extractedText;
          _hasProcessed = true;
        }
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    if (mounted) {
      ref.read(ocrProvider.notifier).reset();
    }
    super.dispose();
  }

  void _handleNext() {
    final bookState = ref.read(bookProvider);

    if (bookState.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('먼저 책을 추가해주세요'),
          backgroundColor: DesignTokens.errorMain,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final extractedText = _textController.text.trim();
    if (extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('텍스트를 입력해주세요'),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.push(
      AppRoutes.addRecord,
      extra: AddRecordScreenParams(
        books: bookState.books,
        initialType: RecordType.snippet,
        initialText: extractedText,
      ),
    );
  }

  void _handleRetake() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ocrProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          title: 'OCR 결과',
          letterSpacing: 2,
        ),
        body: state.isProcessing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: DesignTokens.primaryMain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '텍스트를 인식하는 중...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : state.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: DesignTokens.errorMain,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            state.error!.message,
                            style: AppTypography.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '다시 촬영해주세요',
                            style: AppTypography.bodyMedium.copyWith(
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppButton(
                            text: '재촬영',
                            onPressed: _handleRetake,
                            variant: AppButtonVariant.primary,
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(DesignTokens.space24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 원본 이미지 미리보기
                        ClipRRect(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          child: Image.file(
                            File(widget.imagePath),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 추출된 텍스트 레이블
                        Text(
                          '추출된 텍스트',
                          style: AppTypography.labelMedium.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 텍스트 편집 필드
                        TextField(
                          controller: _textController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: '인식된 텍스트가 여기에 표시됩니다',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 안내 텍스트
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryMain.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: DesignTokens.primaryMain,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'OCR 결과를 확인하고 필요시 수정해주세요',
                                  style: AppTypography.caption.copyWith(
                                    color: DesignTokens.primaryMain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: '재촬영',
                                onPressed: _handleRetake,
                                variant: AppButtonVariant.outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                text: '다음',
                                onPressed: _handleNext,
                                variant: AppButtonVariant.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
