import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Reusable TabBar component with consistent styling
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsetsGeometry? margin;
  final ValueChanged<int>? onTap;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin = const EdgeInsets.symmetric(
      horizontal: DesignTokens.space16,
      vertical: DesignTokens.space8,
    ),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = context.isDark ? Colors.white : DesignTokens.primaryMain;
    final inactiveColor = context.colors.textTertiary;

    return Container(
      margin: margin,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        labelColor: activeColor,
        unselectedLabelColor: inactiveColor,
        indicatorColor: activeColor,
        indicatorWeight: 2,
        dividerHeight: 0,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w300),
        tabs: tabs.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
