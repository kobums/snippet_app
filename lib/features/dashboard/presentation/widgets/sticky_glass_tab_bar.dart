import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';

/// Sticky Neumorphism + Glassmorphism Segmented Button Delegate
///
/// Soft UI 스타일의 세그먼트 버튼. 배경은 글래스모피즘, 버튼은 뉴모피즘.
class StickyGlassSegmentedButton extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final List<String> segments;
  final ValueChanged<int> onChanged;
  final double height;

  StickyGlassSegmentedButton({
    required this.selectedIndex,
    required this.segments,
    required this.onChanged,
    this.height = 64.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: DesignTokens.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            // boxShadow: [
            //   // Neumorphism inset 효과 (오목한 배경)
            //   BoxShadow(
            //     color: Colors.black.withValues(alpha: 0.06),
            //     blurRadius: 4,
            //     offset: const Offset(0, 2),
            //   ),
            //   const BoxShadow(
            //     color: Colors.white,
            //     blurRadius: 4,
            //     offset: Offset(0, -2),
            //   ),
            // ],
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
                              // Neumorphism 볼록 효과
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
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
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
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyGlassSegmentedButton oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex ||
        segments != oldDelegate.segments;
  }
}
