import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';

/// Glass Effect Levels
enum GlassLevel {
  subtle, // 미묘한 효과
  medium, // 중간 효과
  strong, // 강한 효과
}

/// Fintech Style Glass Container
/// 글래스모피즘 효과 — 라이트/다크 테마 자동 대응
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final GlassLevel level;
  final Color? tintColor;
  final bool showBorder;
  final bool showShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.level = GlassLevel.medium,
    this.tintColor,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    final isDark = context.isDark;
    final radius = borderRadius ?? DesignTokens.radiusLg;
    final effectiveColor = _getEffectiveColor(appColors);
    final blurAmount = _getBlurAmount();
    final effectivePadding =
        padding ?? const EdgeInsets.all(DesignTokens.space16);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(radius),
              border: showBorder
                  ? Border.all(color: appColors.glassBorder, width: 1.0)
                  : null,
              gradient: _getGradient(isDark),
              boxShadow: showShadow ? DesignTokens.shadowGlass : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getEffectiveColor(AppColors appColors) {
    if (tintColor != null) return tintColor!;
    switch (level) {
      case GlassLevel.subtle:
        return appColors.glassDark;
      case GlassLevel.medium:
        return appColors.glassMedium;
      case GlassLevel.strong:
        return appColors.glassLight;
    }
  }

  double _getBlurAmount() {
    switch (level) {
      case GlassLevel.subtle:
        return DesignTokens.blurMd;
      case GlassLevel.medium:
        return DesignTokens.blurLg;
      case GlassLevel.strong:
        return DesignTokens.blurXl;
    }
  }

  LinearGradient _getGradient(bool isDark) {
    final highlightAlpha = isDark ? 0.05 : 0.1;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: highlightAlpha),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
  }
}
