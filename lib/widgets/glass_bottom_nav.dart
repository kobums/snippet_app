import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';

/// Navigation Item
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Fintech Style Glass Bottom Navigation Bar
/// 글래스모피즘 하단 내비게이션 — 라이트/다크 테마 자동 대응
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItem> _items = [
    NavItem(
      label: '스니펫',
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
    ),
    NavItem(
      label: '대시보드',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(label: '기록', icon: Icons.edit_outlined, activeIcon: Icons.edit),
    NavItem(
      label: '서재',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
    ),
    NavItem(
      label: '프로필',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    final isDark = context.isDark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final gradientColors = isDark
        ? [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.80),
          ]
        : [
            Colors.white.withValues(alpha: 0.80),
            Colors.white.withValues(alpha: 0.70),
          ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DesignTokens.blurLg,
          sigmaY: DesignTokens.blurLg,
        ),
        child: Container(
          height: 42 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: appColors.glassMedium,
            border: Border(
              top: BorderSide(color: appColors.glassBorder, width: 1.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _items.length,
              (index) => _buildTab(
                context,
                index,
                _items[index],
                currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    int index,
    NavItem item,
    bool isActive,
  ) {
    final appColors = context.colors;
    final activeColor = context.isDark ? Colors.white : DesignTokens.primaryMain;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveEaseOut,
          child: Column(
            children: [
              AnimatedContainer(
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.curveEaseOut,
                width: isActive ? 32 : 0,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            Colors.transparent,
                            activeColor,
                            Colors.transparent,
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              AnimatedSwitcher(
                duration: DesignTokens.durationNormal,
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  size: isActive ? 26 : 24,
                  color: isActive ? activeColor : appColors.textTertiary,
                ),
              ),
              const SizedBox(height: DesignTokens.space4),
            ],
          ),
        ),
      ),
    );
  }
}
