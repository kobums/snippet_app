import 'package:flutter/material.dart';

/// Section Header Size
enum SectionHeaderSize {
  large, // 16px, w300, letterSpacing 1.5
  small, // 14px, w400, letterSpacing 1.0
}

/// Reusable Section Header component
///
/// Provides consistent styling for section titles across the app
class SectionHeader extends StatelessWidget {
  final String title;
  final SectionHeaderSize size;
  final EdgeInsetsGeometry? padding;

  const SectionHeader(
    this.title, {
    super.key,
    this.size = SectionHeaderSize.large,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = size == SectionHeaderSize.large
        ? TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.black.withValues(alpha: 0.6),
          )
        : TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
            color: Colors.black.withValues(alpha: 0.6),
          );

    final text = Text(title, style: textStyle);

    if (padding != null) {
      return Padding(padding: padding!, child: text);
    }
    return text;
  }
}
