import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

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
/// 향상된 글래스모피즘 효과의 하단 내비게이션
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DesignTokens.blurLg,
          sigmaY: DesignTokens.blurLg,
        ),
        child: Container(
          height: 42 + bottomPadding,
          padding: EdgeInsets.only(
            bottom: bottomPadding,
            // top: DesignTokens.space8,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.glassMedium,
            border: Border(
              top: BorderSide(color: DesignTokens.glassBorder, width: 1.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveEaseOut,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicator
              AnimatedContainer(
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.curveEaseOut,
                width: isActive ? 32 : 0,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [
                            Colors.transparent,
                            DesignTokens.primaryMain,
                            Colors.transparent,
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),

              // Icon
              AnimatedSwitcher(
                duration: DesignTokens.durationNormal,
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  size: isActive ? 26 : 24,
                  color: isActive
                      ? DesignTokens.primaryMain
                      : DesignTokens.textTertiary,
                ),
              ),
              const SizedBox(height: DesignTokens.space4),

              // Label
              // AnimatedDefaultTextStyle(
              //   duration: DesignTokens.durationNormal,
              //   curve: DesignTokens.curveEaseOut,
              //   style: AppTypography.captionSmall.copyWith(
              //     color: isActive
              //         ? DesignTokens.primaryMain
              //         : DesignTokens.textTertiary,
              //     fontWeight: isActive
              //         ? DesignTokens.fontMedium
              //         : DesignTokens.fontRegular,
              //   ),
              //   child: Text(item.label),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
