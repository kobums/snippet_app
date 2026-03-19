import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design_tokens.dart';

/// Instagram-style pull-to-refresh indicator
/// 배경 원 없이 얇은 스피너만 표시 + 햅틱 피드백
class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await onRefresh();
      },
      color: DesignTokens.primaryMain,
      backgroundColor: Colors.transparent,
      elevation: 0,
      strokeWidth: 3.0,
      displacement: 20,
      edgeOffset: 0,
      child: child,
    );
  }
}
