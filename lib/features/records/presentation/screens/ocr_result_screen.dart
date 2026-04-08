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
import 'package:snippet_app/features/records/data/models/ocr_result.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

class OcrResultScreen extends ConsumerStatefulWidget {
  final OcrRequest request;

  const OcrResultScreen({super.key, required this.request});

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  final _textController = TextEditingController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        ref.read(ocrProvider.notifier).reset();
        ref.read(ocrProvider.notifier).processImageWithRegions(
          widget.request.imagePath,
          widget.request.regions,
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _textController.dispose();
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

    final text = _textController.text.trim();
    if (text.isEmpty) {
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
        initialText: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ocrProvider);

    ref.listen<OcrState>(ocrProvider, (_, next) {
      if (_isDisposed || !mounted) return;
      if (next.results.isNotEmpty) {
        _textController.text = next.results[0].extractedText;
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppAppBar(title: 'OCR 결과', letterSpacing: 2),
        body: state.isProcessing
            ? _buildLoading()
            : state.error != null
                ? _buildError(state)
                : _buildResult(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: DesignTokens.primaryMain),
          const SizedBox(height: 24),
          Text(
            '텍스트를 인식하는 중...',
            style: AppTypography.bodyMedium.copyWith(color: DesignTokens.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(OcrState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: DesignTokens.errorMain),
            const SizedBox(height: 24),
            Text(
              state.error!.message,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: '다시 시도',
              onPressed: () => context.pop(),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '추출된 텍스트',
                  style: AppTypography.labelMedium.copyWith(color: DesignTokens.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: null,
                  minLines: 6,
                  decoration: InputDecoration(
                    hintText: '인식된 텍스트가 여기에 표시됩니다',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryMain.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: DesignTokens.primaryMain),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OCR 결과를 확인하고 필요시 수정해주세요',
                          style: AppTypography.caption.copyWith(color: DesignTokens.primaryMain),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '재촬영',
                    onPressed: () => context.pop(),
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
}
