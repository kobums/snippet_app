import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/swipe_card.dart';
import '../providers/snippet_provider.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Fintech Style Home Screen
/// Bottom Navigation을 고려한 적절한 spacing
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
          // Cards
          Expanded(
            child: state.isLoading && state.snippets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.snippets.isEmpty
                ? Center(
                    child: Text(
                      "더 이상 카드가 없습니다.\n보관함이나 위젯을 확인해보세요!",
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: state.snippets
                        .take(3) // 상위 3개 카드만 표시 (깊이감을 위해)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final snippet = entry.value;

                          // 뒤에 있는 카드는 살짝 작고 아래로 이동
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
                                  final isLike =
                                      direction == DismissDirection.startToEnd;
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
                        .reversed // 첫 번째 카드가 맨 위에 오도록
                        .toList(),
                  ),
          ),

          // Bottom hint with proper spacing for bottom nav
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '← Pass',
                  style: AppTypography.caption.copyWith(
                    color: DesignTokens.textTertiary,
                  ),
                ),
                const SizedBox(width: DesignTokens.space48),
                Text(
                  'Like →',
                  style: AppTypography.caption.copyWith(
                    color: DesignTokens.textTertiary,
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
