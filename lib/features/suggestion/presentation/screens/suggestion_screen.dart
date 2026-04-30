import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/components/app_input.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/suggestion/data/models/suggestion_dto.dart';
import 'package:snippet_app/features/suggestion/presentation/providers/suggestion_provider.dart';

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  SuggestionCategory _selectedCategory = SuggestionCategory.feature;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _contentError;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      setState(() => _contentError = '내용을 입력해주세요');
      return;
    }
    setState(() => _contentError = null);

    await ref.read(suggestionProvider.notifier).submit(
          SuggestionAddRequestDto(
            category: _selectedCategory,
            title: _titleController.text.trim().isEmpty
                ? null
                : _titleController.text.trim(),
            content: content,
          ),
        );

    if (!mounted) return;

    final state = ref.read(suggestionProvider);
    if (state.isSuccess) {
      ref.read(suggestionProvider.notifier).reset();
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '제안이 접수되었습니다. 감사합니다!',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: DesignTokens.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestionProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          AppAppBar.sliver(
            title: '기능 제안하기',
            leading: BackButton(onPressed: () => context.pop()),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.space24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '원하는 기능이나 불편한 점을 알려주세요.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space24),

                // Category
                Text(
                  '카테고리',
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Wrap(
                  spacing: DesignTokens.space8,
                  runSpacing: DesignTokens.space8,
                  children: SuggestionCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category.label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                      selectedColor:
                          context.colors.primary.withValues(alpha: 0.15),
                      backgroundColor: context.colors.surfaceSecondary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: DesignTokens.space24),

                // Title
                AppInput(
                  controller: _titleController,
                  label: '제목 (선택)',
                  hint: '한 줄로 요약해주세요',
                  maxLength: 200,
                ),
                const SizedBox(height: DesignTokens.space16),

                // Content
                AppInput(
                  controller: _contentController,
                  label: '내용',
                  hint: '자세히 설명해주세요',
                  maxLines: 7,
                  errorText: _contentError,
                  onChanged: (_) {
                    if (_contentError != null) {
                      setState(() => _contentError = null);
                    }
                  },
                ),

                if (state.error != null) ...[
                  const SizedBox(height: DesignTokens.space8),
                  Text(
                    state.error!,
                    style: AppTypography.caption.copyWith(
                      color: DesignTokens.error,
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.space32),

                AppButton(
                  text: '제출하기',
                  isLoading: state.isLoading,
                  isFullWidth: true,
                  onPressed: state.isLoading ? null : _submit,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
