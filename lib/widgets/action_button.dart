import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';
import 'glass_container.dart';

/// Fintech Style Action Button
/// 재사용 가능한 액션 버튼 컴포넌트
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isOutlined;
  final bool isCompact;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.isOutlined = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DesignTokens.primaryMain;
    final verticalPadding = isCompact ? DesignTokens.space12 : DesignTokens.space16;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space20,
          vertical: verticalPadding,
        ),
        level: GlassLevel.subtle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSm,
              color: effectiveColor,
            ),
            const SizedBox(width: DesignTokens.space12),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expanded version that takes full width
class ActionButtonExpanded extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ActionButtonExpanded({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DesignTokens.primaryMain;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.space16,
        ),
        level: GlassLevel.subtle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSm,
              color: effectiveColor,
            ),
            const SizedBox(width: DesignTokens.space12),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
