import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/dashboard/dashboard_providers.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/components/section_header.dart';

class RecommendationCard extends ConsumerWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendAsync = ref.watch(bookRecommendProvider);

    return recommendAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (books) {
        if (books.isEmpty) return const SizedBox.shrink();
        return GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: SectionHeader('✨ 추천 도서')),
                  TextButton(
                    onPressed: () => ref.invalidate(bookRecommendProvider),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space8,
                        vertical: DesignTokens.space4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '새로고침',
                      style: AppTypography.captionSmall.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space12),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: DesignTokens.space12),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusSm),
                              child: book.coverUrl.isNotEmpty
                                  ? Image.network(
                                      book.coverUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(context),
                                    )
                                  : _placeholder(context),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            book.title,
                            style: AppTypography.captionSmall.copyWith(
                              color: context.colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            book.author,
                            style: AppTypography.captionSmall.copyWith(
                              color: context.colors.textTertiary,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (books.first.reason.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.space8),
                Text(
                  books.first.reason,
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.primary.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: context.colors.surfaceSecondary,
        child: Center(
          child: Icon(
            Icons.book_outlined,
            color: context.colors.iconSecondary,
            size: 24,
          ),
        ),
      );
}
