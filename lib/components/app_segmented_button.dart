import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';

/// Reusable Neumorphism-style Segmented Button
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
    return Container(
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: DesignTokens.neutral100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.all(4),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? DesignTokens.textPrimary
                          : DesignTokens.textTertiary,
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
