import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// Reusable Segmented Button
class AppSegmentedButton extends StatelessWidget {
  final int selectedIndex;
  final List<String> segments;
  final ValueChanged<int> onChanged;
  final EdgeInsets? padding;

  const AppSegmentedButton({
    super.key,
    required this.selectedIndex,
    required this.segments,
    required this.onChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return Container(
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: appColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.all(DesignTokens.space4),
        child: Row(
          children: List.generate(segments.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: DesignTokens.durationNormal,
                  curve: DesignTokens.curveEaseInOut,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: appColors.surface,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        )
                      : null,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: DesignTokens.durationNormal,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected ? appColors.textPrimary : appColors.textTertiary,
                    ),
                    child: Text(segments[index]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
