import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Bottom Navigation을 사용하는 화면을 위한 공통 레이아웃
/// extendBody: false 환경에서 FloatingActionButton 영역까지 고려한 적절한 padding 제공
class BottomNavLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasFloatingActionButton;

  const BottomNavLayout({
    super.key,
    required this.child,
    this.padding,
    this.hasFloatingActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // FloatingActionButton이 있는 경우 추가 여백 제공
    final fabPadding = hasFloatingActionButton ? DesignTokens.space64 : 0.0;

    final defaultPadding = EdgeInsets.only(
      left: DesignTokens.space8,
      right: DesignTokens.space8,
      top: DesignTokens.space8,
      bottom: DesignTokens.space8 + fabPadding,
    );

    return SingleChildScrollView(
      padding: padding ?? defaultPadding,
      child: child,
    );
  }
}

/// ListView를 사용하는 화면을 위한 레이아웃
/// extendBody: false 환경에서 FloatingActionButton 영역까지 고려한 적절한 padding 제공
class BottomNavListLayout extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool hasFloatingActionButton;
  final Widget Function(BuildContext, int)? separatorBuilder;

  const BottomNavListLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.hasFloatingActionButton = false,
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // FloatingActionButton이 있는 경우 추가 여백 제공
    final fabPadding = hasFloatingActionButton ? DesignTokens.space64 : 0.0;

    final defaultPadding = EdgeInsets.only(
      left: DesignTokens.space8,
      right: DesignTokens.space8,
      bottom: DesignTokens.space8 + fabPadding,
    );

    if (separatorBuilder != null) {
      return ListView.separated(
        padding: padding ?? defaultPadding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder!,
      );
    }

    return ListView.builder(
      padding: padding ?? defaultPadding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
