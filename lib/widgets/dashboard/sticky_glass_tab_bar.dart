import 'package:flutter/material.dart';
import '../glass_container.dart';
import '../../core/design_tokens.dart';

/// Sticky Glass Segmented Button Delegate for CustomScrollView
///
/// Creates a sticky header with glassmorphism effect that floats above scrolling content.
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
    return Center(
      child: SegmentedButton<int>(
        segments: List.generate(
          segments.length,
          (index) =>
              ButtonSegment<int>(value: index, label: Text(segments[index])),
        ),
        selected: {selectedIndex},
        onSelectionChanged: (Set<int> selected) {
          onChanged(selected.first);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return DesignTokens.primaryMain.withValues(alpha: 0.9);
            }
            return Colors.white.withValues(alpha: 0.15); // Glass effect
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.black.withValues(alpha: 0.7);
          }),
          side: WidgetStateProperty.all(
            BorderSide(
              color: Colors.white.withValues(alpha: 0.5), // Glass border
              width: 1,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
