import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/design_tokens.dart';

/// Fintech Style Loading Shimmer
/// 세련된 로딩 스켈레톤 효과
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
    return Shimmer.fromColors(
      baseColor: DesignTokens.neutral200,
      highlightColor: DesignTokens.neutral100,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ??
              BorderRadius.circular(DesignTokens.radiusSm),
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
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.glassLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: DesignTokens.glassBorder,
          width: 1.0,
        ),
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
