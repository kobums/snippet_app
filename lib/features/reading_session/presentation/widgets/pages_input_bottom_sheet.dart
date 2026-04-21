import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_button.dart';

class PagesInputBottomSheet extends StatefulWidget {
  final int currentPage;
  final int totalPage;
  final ValueChanged<int> onConfirm;

  const PagesInputBottomSheet({
    super.key,
    required this.currentPage,
    required this.totalPage,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentPage,
    required int totalPage,
    required ValueChanged<int> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PagesInputBottomSheet(
        currentPage: currentPage,
        totalPage: totalPage,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<PagesInputBottomSheet> createState() => _PagesInputBottomSheetState();
}

class _PagesInputBottomSheetState extends State<PagesInputBottomSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text);
    if (value == null || value < 0) {
      setState(() => _errorText = '올바른 페이지 번호를 입력하세요');
      return;
    }
    if (widget.totalPage > 0 && value > widget.totalPage) {
      setState(() => _errorText = '총 페이지 수(${{widget.totalPage}})를 초과할 수 없습니다');
      return;
    }
    widget.onConfirm(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radius2xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space24,
        DesignTokens.space24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.neutral300,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.space20),
          Text(
            '현재 페이지 입력',
            style: TextStyle(
              fontSize: DesignTokens.fontSize18,
              fontWeight: DesignTokens.fontMedium,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            '총 ${widget.totalPage}페이지',
            style: TextStyle(
              fontSize: DesignTokens.fontSize14,
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.space20),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: DesignTokens.fontSize32,
              fontWeight: DesignTokens.fontLight,
              color: DesignTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorText: _errorText,
              suffixText: '페이지',
              suffixStyle: TextStyle(
                fontSize: DesignTokens.fontSize16,
                color: DesignTokens.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMd),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusMd),
                borderSide: const BorderSide(
                  color: DesignTokens.primaryMain,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: DesignTokens.space24),
          AppButton(
            text: '확인',
            onPressed: _confirm,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
