import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// App Select Component
/// 드롭다운 선택 위젯
class AppSelect<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final String? errorText;
  final Widget? prefixIcon;

  const AppSelect({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space8),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: enabled
                    ? DesignTokens.textPrimary
                    : DesignTokens.textDisabled,
              ),
            ),
          ),

        // Select Box
        Container(
          decoration: BoxDecoration(
            color: enabled ? DesignTokens.bgPrimary : DesignTokens.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: errorText != null
                  ? DesignTokens.error
                  : DesignTokens.neutral200,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                hint: hint != null
                    ? Text(
                        hint!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: DesignTokens.textTertiary,
                        ),
                      )
                    : null,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? DesignTokens.textSecondary
                      : DesignTokens.textDisabled,
                  size: DesignTokens.iconMd,
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: enabled
                      ? DesignTokens.textPrimary
                      : DesignTokens.textDisabled,
                ),
                dropdownColor: DesignTokens.bgPrimary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space12,
                ),
                items: options.map((option) {
                  return DropdownMenuItem<T>(
                    value: option.value,
                    child: Row(
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon,
                            size: DesignTokens.iconSm,
                            color: DesignTokens.textSecondary,
                          ),
                          const SizedBox(width: DesignTokens.space8),
                        ],
                        Expanded(
                          child: Text(
                            option.label,
                            style: AppTypography.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),

        // Error Text
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: DesignTokens.space4,
              left: DesignTokens.space12,
            ),
            child: Text(
              errorText!,
              style: AppTypography.caption.copyWith(color: DesignTokens.error),
            ),
          ),
      ],
    );
  }
}

/// Select Option Model
class AppSelectOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppSelectOption({required this.value, required this.label, this.icon});
}
