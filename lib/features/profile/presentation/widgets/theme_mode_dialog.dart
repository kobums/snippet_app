import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// [ThemeModeDialog.show]로 테마 선택 다이얼로그를 표시합니다.
class ThemeModeDialog {
  ThemeModeDialog._();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) =>
          _ThemeModeDialogContent(initial: current, onApply: notifier.setMode),
    );
  }
}

class _ThemeModeDialogContent extends StatefulWidget {
  final ThemeMode initial;
  final void Function(ThemeMode) onApply;

  const _ThemeModeDialogContent({required this.initial, required this.onApply});

  @override
  State<_ThemeModeDialogContent> createState() =>
      _ThemeModeDialogContentState();
}

class _ThemeModeDialogContentState extends State<_ThemeModeDialogContent> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  void _apply() {
    widget.onApply(_selected);
    Navigator.pop(context);
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colors),
            Flexible(
              child: SingleChildScrollView(child: _buildOptions(colors)),
            ),
            _buildFooter(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '테마 설정',
            style: AppTypography.h4.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            '앱의 색상 테마를 선택하세요',
            style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space12,
      ),
      child: Column(
        children: ThemeMode.values.map((mode) {
          return _ThemeOptionTile(
            mode: mode,
            isSelected: _selected == mode,
            onTap: () => setState(() => _selected = mode),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(AppColors colors) {
    return Column(
      children: [
        Divider(color: colors.border, height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '취소',
                  variant: AppButtonVariant.neutral,
                  isFullWidth: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Expanded(
                child: AppButton(
                  text: '적용',
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  String get _label => switch (mode) {
    ThemeMode.system => '시스템 설정 따르기',
    ThemeMode.light => '라이트 모드',
    ThemeMode.dark => '다크 모드',
  };

  String get _description => switch (mode) {
    ThemeMode.system => '기기 설정에 맞게 자동 전환',
    ThemeMode.light => '항상 밝은 화면 사용',
    ThemeMode.dark => '항상 어두운 화면 사용',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    final selectedBg = isDark
        ? colors.surfaceSecondary
        : DesignTokens.primaryMain.withValues(alpha: 0.05);
    final selectedBorder = isDark
        ? colors.border
        : DesignTokens.primaryMain.withValues(alpha: 0.2);
    final iconBg = isSelected
        ? (isDark
              ? colors.primary.withValues(alpha: 0.15)
              : DesignTokens.primaryMain.withValues(alpha: 0.08))
        : colors.surfaceSecondary;
    final iconColor = isSelected ? colors.primary : colors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        curve: DesignTokens.curveEaseOut,
        margin: const EdgeInsets.only(bottom: DesignTokens.space8),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: isSelected ? selectedBorder : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: DesignTokens.durationFast,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(_icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _description,
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: DesignTokens.durationFast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: context.isDark
                          ? DesignTokens.darkBgPrimary
                          : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
