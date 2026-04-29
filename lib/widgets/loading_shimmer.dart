import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';

/// Fintech Style Loading Shimmer
/// 로딩 스켈레톤 효과 — 라이트/다크 테마 자동 대응
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return Shimmer.fromColors(
      baseColor: appColors.shimmerBase,
      highlightColor: appColors.shimmerHighlight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius:
              borderRadius ?? BorderRadius.circular(DesignTokens.radiusSm),
        ),
      ),
    );
  }
}

/// Book Card Shimmer
class BookCardShimmer extends StatelessWidget {
  const BookCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: appColors.glassLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: appColors.glassBorder, width: 1.0),
      ),
      child: const Row(
        children: [
          LoadingShimmer(
            width: 60,
            height: 90,
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusSm),
            ),
          ),
          SizedBox(width: DesignTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(
                    Radius.circular(DesignTokens.radiusXs),
                  ),
                ),
                SizedBox(height: DesignTokens.space8),
                LoadingShimmer(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.all(
                    Radius.circular(DesignTokens.radiusXs),
                  ),
                ),
                SizedBox(height: DesignTokens.space16),
                LoadingShimmer(
                  width: double.infinity,
                  height: 6,
                  borderRadius: BorderRadius.all(
                    Radius.circular(DesignTokens.radiusXs),
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
