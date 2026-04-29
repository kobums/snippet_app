import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// Glass 스타일 검색 필드 컴포넌트
class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry margin;

  const SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '검색...',
    required this.onChanged,
    this.onClear,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateState);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() => _hasText = _controller.text.isNotEmpty);
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: appColors.border, width: 1),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        scrollPadding: EdgeInsets.zero,
        style: AppTypography.bodyMedium.copyWith(color: appColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
            color: appColors.textTertiary,
          ),
          prefixIcon: Icon(Icons.search, color: appColors.iconSecondary),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.clear, color: appColors.iconSecondary),
                  onPressed: _handleClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: DesignTokens.space12),
        ),
      ),
    );
  }
}

/// 스크롤 시 제자리에서 fade-out 되는 SearchField + 스크롤 콘텐츠 레이아웃
class SearchableScrollLayout extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Widget child;
  final double fadeDistance;

  const SearchableScrollLayout({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '검색...',
    required this.onChanged,
    this.onClear,
    required this.child,
    this.fadeDistance = 60.0,
  });

  @override
  State<SearchableScrollLayout> createState() => _SearchableScrollLayoutState();
}

class _SearchableScrollLayoutState extends State<SearchableScrollLayout> {
  double _scrollOffset = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      setState(() => _scrollOffset = notification.metrics.pixels);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - _scrollOffset / widget.fadeDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),
        IgnorePointer(
          ignoring: opacity < 0.1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: opacity,
            child: SearchField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              hintText: widget.hintText,
              onChanged: widget.onChanged,
              onClear: widget.onClear,
            ),
          ),
        ),
      ],
    );
  }
}
