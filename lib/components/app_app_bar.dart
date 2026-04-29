import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Fintech Style App Bar
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
    final appColors = context.colors;

    return AppBar(
      backgroundColor: appColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: AppTypography.h3.copyWith(
          letterSpacing: letterSpacing ?? DesignTokens.letterSpacingWide,
          color: appColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: appColors.textPrimary, size: 20),
      actions: actions,
      bottom: bottom,
    );
  }

  /// 스크롤 시 숨겨지는 SliverAppBar — 내부적으로 _AppSliverAppBar 위젯 반환
  static Widget sliver({
    required String title,
    double? letterSpacing,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool pinned = false,
    Widget? leading,
    bool automaticallyImplyLeading = false,
  }) {
    return _AppSliverAppBar(
      title: title,
      letterSpacing: letterSpacing,
      actions: actions,
      bottom: bottom,
      pinned: pinned,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// SliverAppBar 래퍼 — build() 에서 context 접근 가능
class _AppSliverAppBar extends StatelessWidget {
  final String title;
  final double? letterSpacing;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const _AppSliverAppBar({
    required this.title,
    this.letterSpacing,
    this.actions,
    this.bottom,
    this.pinned = false,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return SliverAppBar(
      backgroundColor: appColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      floating: false,
      snap: false,
      pinned: pinned,
      centerTitle: true,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: AppTypography.h3.copyWith(
          letterSpacing: letterSpacing ?? DesignTokens.letterSpacingWide,
          color: appColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: appColors.textPrimary, size: 20),
      actions: actions,
      bottom: bottom,
    );
  }
}
