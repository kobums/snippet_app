import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/snippet/presentation/widgets/swipe_card.dart';
import 'package:snippet_app/features/snippet/presentation/providers/snippet_provider.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(snippetProvider.notifier).fetchSnippets());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snippetProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: state.isLoading && state.snippets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.snippets.isEmpty
                    ? Center(
                        child: state.isDailyLimitReached
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🌙', style: TextStyle(fontSize: 52)),
                                  const SizedBox(height: DesignTokens.space16),
                                  Text(
                                    '오늘의 스니펫을 모두 읽었어요',
                                    style: AppTypography.h3.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.space8),
                                  Text(
                                    '내일 다시 새로운 문장을 만나보세요',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.space4),
                                  Text(
                                    '하루 5문장 · 매일 자정 초기화',
                                    style: AppTypography.caption.copyWith(
                                      color: context.colors.textTertiary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '더 이상 카드가 없습니다.\n보관함이나 위젯을 확인해보세요!',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: state.snippets
                            .take(3)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final snippet = entry.value;
                              final scale = 1.0 - (index * 0.05);
                              final offset = index * 8.0;

                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Dismissible(
                                    key: ValueKey(snippet.id),
                                    direction: DismissDirection.horizontal,
                                    onDismissed: (direction) {
                                      final isLike = direction ==
                                          DismissDirection.startToEnd;
                                      ref
                                          .read(snippetProvider.notifier)
                                          .handleSwipe(snippet.id, isLike);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: DesignTokens.space24,
                                        right: DesignTokens.space24,
                                        bottom: DesignTokens.space48,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 400,
                                        ),
                                        child: SwipeCard(snippet: snippet),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList()
                            .reversed
                            .toList(),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '← Pass',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
                const SizedBox(width: DesignTokens.space48),
                Text(
                  'Like →',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
