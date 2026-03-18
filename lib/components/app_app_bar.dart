import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Fintech Style App Bar
/// 일관된 스타일의 AppBar 컴포넌트
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final double? letterSpacing;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.letterSpacing,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DesignTokens.bgSecondary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: AppTypography.h3.copyWith(
          letterSpacing: letterSpacing ?? DesignTokens.letterSpacingWide,
          color: DesignTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: DesignTokens.textPrimary, size: 20),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
