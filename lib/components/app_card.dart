import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Card Variants
enum AppCardVariant {
  elevated,  // 떠있는 카드 (그림자 있음)
  flat,      // 평평한 카드 (그림자 없음)
  glass,     // 글래스모피즘 카드
  outlined,  // 테두리만 있는 카드
}

/// Fintech Style App Card
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
    final appColors = context.colors;
    final radius = borderRadius ?? DesignTokens.radiusLg;

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.space16),
      decoration: _getDecoration(radius, appColors),
      child: child,
    );

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

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: appColors.primary.withValues(alpha: 0.1),
          highlightColor: appColors.primary.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return Container(margin: margin, child: cardContent);
  }

  BoxDecoration _getDecoration(double radius, AppColors appColors) {
    switch (variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? appColors.cardBackground,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: DesignTokens.shadowMd,
        );

      case AppCardVariant.flat:
        return BoxDecoration(
          color: backgroundColor ?? appColors.cardBackground,
          borderRadius: BorderRadius.circular(radius),
        );

      case AppCardVariant.glass:
        return BoxDecoration(
          color: backgroundColor ?? appColors.glassLight,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: appColors.glassBorder, width: 1.0),
          boxShadow: DesignTokens.shadowGlass,
        );

      case AppCardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: appColors.border, width: 1.0),
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
    final appColors = context.colors;
    final color = valueColor ?? appColors.primary;

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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(icon, size: DesignTokens.iconMd, color: color),
            ),
            const SizedBox(height: DesignTokens.space12),
          ],
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              fontWeight: DesignTokens.fontLight,
              color: color,
              height: DesignTokens.lineHeightTight,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: DesignTokens.fontRegular,
              color: appColors.textSecondary,
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
    final appColors = context.colors;
    final color = iconColor ?? appColors.primary;

    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(icon, color: color, size: DesignTokens.iconMd),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: appColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DesignTokens.space4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: appColors.textSecondary,
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
