import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class SessionTimerDisplay extends StatelessWidget {
  final String formattedTime;
  final bool isPaused;

  const SessionTimerDisplay({
    super.key,
    required this.formattedTime,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isPaused ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        formattedTime,
        style: AppTypography.displayLarge.copyWith(
          fontSize: DesignTokens.fontSize72,
          fontWeight: DesignTokens.fontLight,
          color: Colors.white,
          letterSpacing: 4,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
