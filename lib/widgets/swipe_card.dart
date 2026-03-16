import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../models/snippet.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Fintech Style Swipe Card
/// 세련된 스와이프 카드 with 디자인 토큰
class SwipeCard extends StatelessWidget {
  final Snippet snippet;

  const SwipeCard({super.key, required this.snippet});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(DesignTokens.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tag
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space12,
                vertical: DesignTokens.space4,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.primaryMain.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(
                  color: DesignTokens.primaryMain.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                snippet.tag,
                style: AppTypography.caption.copyWith(
                  color: DesignTokens.primaryMain,
                  fontWeight: DesignTokens.fontMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space20),

          // Quote Text
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: const BoxConstraints(minHeight: 180),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '"${snippet.text}"',
                      style: AppTypography.quote.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (snippet.bookTitle != null) ...[
                      const SizedBox(height: DesignTokens.space20),
                      Text(
                        snippet.bookTitle!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Divider
          const SizedBox(height: DesignTokens.space24),
          Container(
            width: 48,
            height: 2,
            decoration: BoxDecoration(
              color: DesignTokens.neutral300,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
            ),
          ),
        ],
      ),
    );
  }
}
