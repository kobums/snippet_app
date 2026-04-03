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
  final dynamic imagePathOrPaths; // String 또는 List<String>

  const OcrResultScreen({super.key, required this.imagePathOrPaths});

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  late List<TextEditingController> _textControllers;
  late List<String> _imagePaths;
  bool _isMultiple = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // 단일/다중 구분
    if (widget.imagePathOrPaths is List<String>) {
      _isMultiple = true;
      _imagePaths = widget.imagePathOrPaths as List<String>;
      _textControllers = List.generate(
        _imagePaths.length,
        (_) => TextEditingController(),
      );
    } else {
      _isMultiple = false;
      _imagePaths = [widget.imagePathOrPaths as String];
      _textControllers = [TextEditingController()];
    }

    // OCR 처리 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        if (_isMultiple) {
          ref.read(ocrProvider.notifier).processMultipleImages(_imagePaths);
        } else {
          ref.read(ocrProvider.notifier).processImage(_imagePaths[0]);
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final controller in _textControllers) {
      controller.dispose();
    }
    ref.read(ocrProvider.notifier).reset();
    super.dispose();
  }

  void _removeResult(int index) {
    setState(() {
      _imagePaths.removeAt(index);
      _textControllers[index].dispose();
      _textControllers.removeAt(index);
    });
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

    // 모든 텍스트 합치기
    final allTexts = _textControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final combinedText = allTexts.join('\n\n');

    if (combinedText.isEmpty) {
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
        initialText: combinedText,
      ),
    );
  }

  void _handleRetake() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ocrProvider);

    // OCR 결과를 감지하여 텍스트 필드에 채우기
    ref.listen<OcrState>(
      ocrProvider,
      (previous, next) {
        if (!_isDisposed && !mounted) return;

        if (_isMultiple && next.results.isNotEmpty) {
          for (int i = 0;
              i < next.results.length && i < _textControllers.length;
              i++) {
            _textControllers[i].text = next.results[i].extractedText;
          }
        } else if (!_isMultiple && next.results.isNotEmpty) {
          _textControllers[0].text = next.results[0].extractedText;
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppAppBar(
          title: 'OCR 결과',
          letterSpacing: 2,
        ),
        body: state.isProcessing
            ? _buildProgressIndicator(state)
            : state.error != null
                ? _buildErrorView(state)
                : _isMultiple
                    ? _buildMultipleResults(state)
                    : _buildSingleResult(state),
      ),
    );
  }

  Widget _buildProgressIndicator(OcrState state) {
    return Center(
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
          if (_isMultiple && state.totalCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${state.currentIndex + 1} / ${state.totalCount}',
              style: AppTypography.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(OcrState state) {
    return Center(
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
    );
  }

  Widget _buildMultipleResults(OcrState state) {
    return Column(
      children: [
        // 안내 메시지
        Container(
          padding: const EdgeInsets.all(12),
          color: DesignTokens.primaryMain.withValues(alpha: 0.1),
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
                  '${_imagePaths.length}개의 밑줄 영역을 인식했습니다',
                  style: AppTypography.bodySmall.copyWith(
                    color: DesignTokens.primaryMain,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 결과 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignTokens.primaryMain
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(DesignTokens.radiusSm),
                            ),
                            child: Text(
                              '밑줄 ${index + 1}',
                              style: AppTypography.caption.copyWith(
                                color: DesignTokens.primaryMain,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // 개별 삭제 버튼
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removeResult(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 크롭된 이미지
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusSm),
                        child: Image.file(
                          File(_imagePaths[index]),
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 텍스트 필드
                      TextField(
                        controller: _textControllers[index],
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: '인식된 텍스트',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 하단 버튼
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
          ),
        ),
      ],
    );
  }

  Widget _buildSingleResult(OcrState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 원본 이미지 미리보기
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Image.file(
              File(_imagePaths[0]),
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
            controller: _textControllers[0],
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
    );
  }
}
