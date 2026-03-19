import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// Fintech Style Settings Tile
/// 세련된 설정 타일 with 디자인 토큰
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        splashColor: DesignTokens.primaryMain.withValues(alpha: 0.1),
        highlightColor: DesignTokens.primaryMain.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.space12,
            horizontal: DesignTokens.space4,
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignTokens.primaryMain.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: DesignTokens.primaryMain,
                  size: DesignTokens.iconMd,
                ),
              ),
              const SizedBox(width: DesignTokens.space16),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: DesignTokens.textTertiary,
                size: DesignTokens.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
