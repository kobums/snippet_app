import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Glass Effect Levels
enum GlassLevel {
  subtle, // 미묘한 효과
  medium, // 중간 효과
  strong, // 강한 효과
}

/// Fintech Style Glass Container
/// 향상된 글래스모피즘 효과를 제공하는 컨테이너
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
    final radius = borderRadius ?? DesignTokens.radiusLg;
    final effectiveColor = _getEffectiveColor();
    final blurAmount = _getBlurAmount();

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(radius),
              border: showBorder
                  ? Border.all(color: DesignTokens.glassBorder, width: 1.0)
                  : null,
              gradient: _getGradient(),
              boxShadow: showShadow ? DesignTokens.shadowGlass : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getEffectiveColor() {
    if (tintColor != null) {
      return tintColor!;
    }

    switch (level) {
      case GlassLevel.subtle:
        return DesignTokens.glassDark;
      case GlassLevel.medium:
        return DesignTokens.glassMedium;
      case GlassLevel.strong:
        return DesignTokens.glassLight;
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

  LinearGradient? _getGradient() {
    // 미묘한 그라디언트 오버레이로 깊이감 추가
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 1.0],
    );
  }
}
