import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/components/app_button.dart';

/// 앱 디자인 시스템 기반 커스텀 다이얼로그
///
/// Material AlertDialog 대신 사용하는 디자인 일관 컴포넌트.
/// [AppDialog.show]로 띄우거나 직접 위젯으로 사용 가능.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;

  /// null이면 버튼 영역 숨김
  final List<AppDialogAction>? actions;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<AppDialogAction>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: title, colors: colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space24,
                0,
                DesignTokens.space24,
                DesignTokens.space8,
              ),
              child: content,
            ),
            if (actions != null && actions!.isNotEmpty)
              _Actions(actions: actions!, colors: colors),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final AppColors colors;

  const _Header({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space16,
      ),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final List<AppDialogAction> actions;
  final AppColors colors;

  const _Actions({required this.actions, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: colors.border, height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: DesignTokens.space8),
                Expanded(
                  child: AppButton(
                    text: actions[i].label,
                    onPressed: actions[i].onPressed,
                    variant: actions[i].isPrimary
                        ? AppButtonVariant.primary
                        : AppButtonVariant.outlined,
                    size: AppButtonSize.medium,
                    isFullWidth: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AppDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const AppDialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });
}
