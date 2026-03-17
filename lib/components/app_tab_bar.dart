import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Reusable TabBar component with consistent styling
class AppTabBar extends StatelessWidget {
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
    return Container(
      margin: margin,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        labelColor: DesignTokens.primaryMain,
        unselectedLabelColor: DesignTokens.textTertiary,
        indicatorColor: DesignTokens.primaryMain,
        indicatorWeight: 2,
        dividerHeight: 0,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        tabs: tabs.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
