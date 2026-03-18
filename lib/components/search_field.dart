import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

/// Reusable Search Field component
class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.hintText = '검색...',
    required this.onChanged,
    this.onClear,
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
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateState() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                onPressed: _handleClear,
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    );
  }
}
