import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Reusable FloatingActionButton component with consistent styling
class AppFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? DesignTokens.primaryMain;
    final fgColor = foregroundColor ?? Colors.white;

    if (label != null) {
      // Extended FAB with label
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        icon: Icon(icon),
        label: Text(
          label!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // Regular FAB
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      child: Icon(icon),
    );
  }
}
