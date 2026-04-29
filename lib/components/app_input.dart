import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Input Variants
enum AppInputVariant {
  standard, // 기본 입력 필드
  filled, // 채워진 배경
  outlined, // 테두리만
}

/// Fintech Style App Input Field
/// 일관된 스타일의 입력 필드 컴포넌트
class AppInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final AppInputVariant variant;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.variant = AppInputVariant.filled,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
        ],
        AnimatedContainer(
          duration: DesignTokens.durationFast,
          curve: DesignTokens.curveEaseOut,
          decoration: _getContainerDecoration(),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.textTertiary,
              ),
              errorText: widget.errorText,
              helperText: widget.helperText,
              helperStyle: AppTypography.caption,
              errorStyle: AppTypography.caption.copyWith(
                color: DesignTokens.error,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? (context.isDark ? Colors.white : DesignTokens.primaryMain)
                          : context.colors.textTertiary,
                      size: DesignTokens.iconMd,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: _getBorder(),
              enabledBorder: _getBorder(),
              focusedBorder: _getFocusedBorder(),
              errorBorder: _getErrorBorder(),
              focusedErrorBorder: _getErrorBorder(),
              filled: widget.variant == AppInputVariant.filled,
              fillColor: widget.variant == AppInputVariant.filled
                  ? context.colors.inputFill
                  : Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: DesignTokens.space12,
              ),
              counterStyle: AppTypography.caption,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _getContainerDecoration() {
    if (widget.variant == AppInputVariant.standard) {
      final focusColor = context.isDark ? Colors.white : DesignTokens.primaryMain;
      return BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? focusColor : context.colors.border,
            width: _isFocused ? 2.0 : 1.0,
          ),
        ),
      );
    }
    return const BoxDecoration();
  }

  InputBorder _getBorder() {
    switch (widget.variant) {
      case AppInputVariant.standard:
        return InputBorder.none;
      case AppInputVariant.filled:
      case AppInputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: context.colors.border, width: 1.0),
        );
    }
  }

  InputBorder _getFocusedBorder() {
    final focusColor = context.isDark ? Colors.white : DesignTokens.primaryMain;
    switch (widget.variant) {
      case AppInputVariant.standard:
        return InputBorder.none;
      case AppInputVariant.filled:
      case AppInputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: focusColor, width: 2.0),
        );
    }
  }

  InputBorder _getErrorBorder() {
    switch (widget.variant) {
      case AppInputVariant.standard:
        return InputBorder.none;
      case AppInputVariant.filled:
      case AppInputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(
            color: DesignTokens.error,
            width: _isFocused ? 2.0 : 1.0,
          ),
        );
    }
  }
}

/// Password Input Field
class AppPasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const AppPasswordInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      enabled: widget.enabled,
      obscureText: !_isVisible,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _isVisible ? Icons.visibility_off : Icons.visibility,
          color: context.colors.textTertiary,
          size: DesignTokens.iconMd,
        ),
        onPressed: () {
          setState(() {
            _isVisible = !_isVisible;
          });
        },
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
    );
  }
}
