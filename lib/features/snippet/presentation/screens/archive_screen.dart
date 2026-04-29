import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/snippet/presentation/providers/snippet_provider.dart';
import 'package:snippet_app/features/snippet/data/models/snippet_archive.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archiveState = ref.watch(archiveProvider);

    return SafeArea(
      bottom: false,
      child: archiveState.when(
        data: (snippets) {
          if (snippets.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.only(
              left: DesignTokens.space16,
              right: DesignTokens.space16,
              top: DesignTokens.space16,
              bottom: DesignTokens.space16,
            ),
            itemCount: snippets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return ArchiveCard(snippet: snippets[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final appColors = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📖', style: AppTypography.displayLarge),
        const SizedBox(height: DesignTokens.space16),
        Text(
          '아직 모은 문장이 없어요',
          style: AppTypography.h4.copyWith(color: appColors.textSecondary),
        ),
        const SizedBox(height: DesignTokens.space8),
        Text(
          '마음에 드는 문장을 오른쪽으로 스와이프하면\n여기에 모을 수 있어요',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: appColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class ArchiveCard extends StatefulWidget {
  final SnippetArchive snippet;
  const ArchiveCard({super.key, required this.snippet});

  @override
  State<ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<ArchiveCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space24),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
          border: Border.all(color: appColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: appColors.overlay,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.snippet.tag != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: appColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  widget.snippet.tag!,
                  style: AppTypography.labelSmall.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
              ),
            if (widget.snippet.tag != null)
              const SizedBox(height: DesignTokens.space12),
            Text(
              '"${widget.snippet.text}"',
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w300,
                color: appColors.textPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
            // Text(
            //   _isExpanded ? '탭하여 닫기' : '탭하여 책 정보 보기',
            //   style: AppTypography.labelSmall.copyWith(color: appColors.textTertiary),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ' ${widget.snippet.bookTitle} - ${widget.snippet.bookAuthor} ',
                  style: AppTypography.labelSmall.copyWith(
                    color: appColors.textTertiary,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _isExpanded
                  ? _buildBookDetails(context, appColors)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookDetails(BuildContext context, AppColors appColors) {
    final s = widget.snippet;
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.space16),
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: appColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s.coverUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              child: Image.network(
                s.coverUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(appColors),
              ),
            )
          else
            _buildPlaceholder(appColors),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.bookTitle,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  s.bookAuthor,
                  style: AppTypography.labelSmall.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                GestureDetector(
                  onTap: () async {
                    if (s.affiliateUrl.isNotEmpty) {
                      final uri = Uri.parse(s.affiliateUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                      vertical: DesignTokens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull,
                      ),
                    ),
                    child: Text(
                      '이 책 구매하기',
                      style: AppTypography.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(AppColors appColors) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Icon(Icons.book, color: appColors.textTertiary),
    );
  }
}
