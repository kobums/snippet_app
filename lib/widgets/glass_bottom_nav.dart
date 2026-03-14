import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary; 
    final tertiaryColor = Colors.black.withOpacity(0.35);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          height: 64 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab(context, 0, '스와이프', '◇', currentIndex == 0, accentColor, tertiaryColor),
              _buildTab(context, 1, '대시보드', '☰', currentIndex == 1, accentColor, tertiaryColor),
              _buildTab(context, 2, '기록', '✎', currentIndex == 2, accentColor, tertiaryColor),
              _buildTab(context, 3, '보관함', '♡', currentIndex == 3, accentColor, tertiaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, String icon, bool isActive, Color accent, Color tertiary) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              Positioned(
                top: 0,
                child: Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, accent, Colors.transparent],
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 22,
                    color: isActive ? accent : tertiary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? accent : tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
