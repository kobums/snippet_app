import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Button Variants
enum AppButtonVariant {
  primary, // Filled primary color
  secondary, // Filled secondary color
  outlined, // Outlined primary
  ghost, // Text only
  danger, // Red for destructive actions
}

/// Button Sizes
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Fintech Style App Button
/// 일관된 스타일의 버튼 컴포넌트
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curveEaseOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          height: height,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: buttonStyle,
            child: Padding(
              padding: padding,
              child: widget.isLoading
                  ? _buildLoader()
                  : _buildContent(textStyle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    final loaderColor = _getLoaderColor();
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: _getIconSize()),
          const SizedBox(width: DesignTokens.space8),
          Text(widget.text, style: textStyle),
        ],
      );
    }
    return Text(widget.text, style: textStyle);
  }

  ButtonStyle _getButtonStyle() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DesignTokens.radiusMd)),
          ),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.secondaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DesignTokens.radiusMd)),
          ),
        );

      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          disabledForegroundColor: DesignTokens.textDisabled,
          side: const BorderSide(
            color: DesignTokens.primaryMain,
            width: 1.5,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DesignTokens.radiusMd)),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        );

      case AppButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          disabledForegroundColor: DesignTokens.textDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DesignTokens.radiusMd)),
          ),
        );

      case AppButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DesignTokens.radiusMd)),
          ),
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return DesignTokens.buttonHeightSm;
      case AppButtonSize.medium:
        return DesignTokens.buttonHeightMd;
      case AppButtonSize.large:
        return DesignTokens.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.space24,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.space32,
        );
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.size == AppButtonSize.small
        ? AppTypography.buttonSmall
        : AppTypography.button;

    final color = _getTextColor();
    return baseStyle.copyWith(color: color);
  }

  Color _getTextColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return DesignTokens.textDisabled;
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outlined:
      case AppButtonVariant.ghost:
        return DesignTokens.primaryMain;
    }
  }

  Color _getLoaderColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outlined:
      case AppButtonVariant.ghost:
        return DesignTokens.primaryMain;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return DesignTokens.iconSm;
      case AppButtonSize.medium:
        return DesignTokens.iconMd;
      case AppButtonSize.large:
        return DesignTokens.iconLg;
    }
  }
}
