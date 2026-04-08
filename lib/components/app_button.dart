import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Button Variants
enum AppButtonVariant {
  primary, // Filled primary color
  secondary, // Filled secondary color
  outlined, // Outlined primary
  outlinedDanger, // Outlined danger (red border)
  ghost, // Text only
  danger, // Red for destructive actions
}

/// Button Sizes
enum AppButtonSize { small, medium, large }

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
      CurvedAnimation(parent: _controller, curve: DesignTokens.curveEaseOut),
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

    final style = buttonStyle.copyWith(
      padding: WidgetStateProperty.all(padding),
      minimumSize: WidgetStateProperty.all(Size(0, height)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

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
            style: style,
            child: widget.isLoading ? _buildLoader() : _buildContent(textStyle),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(widget.icon, size: _getIconSize()),
          const SizedBox(width: DesignTokens.space8),
          Flexible(
            child: Text(
              widget.text,
              style: textStyle.copyWith(height: 1.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    return Text(
      widget.text,
      style: textStyle.copyWith(height: 1.0),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 2,
          shadowColor: DesignTokens.primaryMain.withValues(alpha: 0.3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
          ),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.secondaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 2,
          shadowColor: DesignTokens.secondaryMain.withValues(alpha: 0.3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
          ),
        );

      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          disabledForegroundColor: DesignTokens.textDisabled,
          side: const BorderSide(color: DesignTokens.primaryMain, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(0),
        );

      case AppButtonVariant.outlinedDanger:
        return OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.error,
          disabledForegroundColor: DesignTokens.textDisabled,
          side: const BorderSide(color: DesignTokens.error, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(0),
        );

      case AppButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          disabledForegroundColor: DesignTokens.textDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
          ),
        );

      case AppButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          elevation: 2,
          shadowColor: DesignTokens.error.withValues(alpha: 0.3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusLg),
            ),
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
        return const EdgeInsets.symmetric(horizontal: DesignTokens.space12);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: DesignTokens.space12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: DesignTokens.space12);
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
      case AppButtonVariant.outlinedDanger:
        return DesignTokens.error;
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
      case AppButtonVariant.outlinedDanger:
        return DesignTokens.error;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 18.0; // 14px 텍스트에 맞춤
      case AppButtonSize.medium:
        return DesignTokens.iconSm; // 20px
      case AppButtonSize.large:
        return DesignTokens.iconSm; // 20px (16px 텍스트에 맞춤)
    }
  }
}
