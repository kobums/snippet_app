import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/typography.dart';

/// Section Header Size
enum SectionHeaderSize {
  large, // 16px, w600, letterSpacing 1.5
  small, // 14px, w400, letterSpacing 1.0
}

/// Reusable Section Header component
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
    final color = context.colors.textSecondary;
    final textStyle = size == SectionHeaderSize.large
        ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5, color: color)
        : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w400, letterSpacing: 1.0, color: color);

    final text = Text(title, style: textStyle);
    if (padding != null) return Padding(padding: padding!, child: text);
    return text;
  }
}
