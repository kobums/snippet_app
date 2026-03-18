import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/design_tokens.dart';

/// Card Variants
enum AppCardVariant {
  elevated, // 떠있는 카드 (그림자 있음)
  flat, // 평평한 카드 (그림자 없음)
  glass, // 글래스모피즘 카드
  outlined, // 테두리만 있는 카드
}

/// Fintech Style App Card
/// 일관된 스타일의 카드 컴포넌트
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? DesignTokens.radiusLg;

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.space16),
      decoration: _getDecoration(radius),
      child: child,
    );

    // Glass variant needs backdrop filter
    if (variant == AppCardVariant.glass) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DesignTokens.blurXl,
            sigmaY: DesignTokens.blurXl,
          ),
          child: cardContent,
        ),
      );
    }

    // Wrap with Material for ink splash effect
    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: DesignTokens.primaryMain.withValues(alpha: 0.1),
          highlightColor: DesignTokens.primaryMain.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return Container(margin: margin, child: cardContent);
  }

  BoxDecoration _getDecoration(double radius) {
    switch (variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.bgPrimary,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: DesignTokens.shadowMd,
        );

      case AppCardVariant.flat:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.bgPrimary,
          borderRadius: BorderRadius.circular(radius),
        );

      case AppCardVariant.glass:
        return BoxDecoration(
          color: backgroundColor ?? DesignTokens.glassLight,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: DesignTokens.glassBorder, width: 1.0),
          boxShadow: DesignTokens.shadowGlass,
        );

      case AppCardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: DesignTokens.neutral300, width: 1.0),
        );
    }
  }
}

/// Stats Card - 통계 표시용 카드
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glass,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: (valueColor ?? DesignTokens.primaryMain).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                icon,
                size: DesignTokens.iconMd,
                color: valueColor ?? DesignTokens.primaryMain,
              ),
            ),
            const SizedBox(height: DesignTokens.space12),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: DesignTokens.fontSize32,
              fontWeight: DesignTokens.fontLight,
              color: valueColor ?? DesignTokens.primaryMain,
              height: DesignTokens.lineHeightTight,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize12,
              fontWeight: DesignTokens.fontRegular,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Card - 정보 표시용 카드
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? DesignTokens.primaryMain).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              icon,
              color: iconColor ?? DesignTokens.primaryMain,
              size: DesignTokens.iconMd,
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSize16,
                    fontWeight: DesignTokens.fontMedium,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: DesignTokens.fontSize12,
                      fontWeight: DesignTokens.fontRegular,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DesignTokens.space8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
