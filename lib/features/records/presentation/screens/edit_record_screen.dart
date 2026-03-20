import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class EditRecordScreen extends ConsumerStatefulWidget {
  final RecordDto record;

  const EditRecordScreen({super.key, required this.record});

  @override
  ConsumerState<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends ConsumerState<EditRecordScreen> {
  late TextEditingController _textController;
  late TextEditingController _tagController;
  late TextEditingController _pageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.record.text);
    _tagController = TextEditingController(text: widget.record.tag ?? '');
    _pageController = TextEditingController(
      text: widget.record.relatedPage?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _tagController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _updateRecord() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내용을 입력해주세요'),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updates = {
      'text': _textController.text.trim(),
      'tag': _tagController.text.trim().isEmpty
          ? null
          : _tagController.text.trim(),
      'relatedPage': _pageController.text.trim().isEmpty
          ? null
          : int.tryParse(_pageController.text.trim()),
    };

    try {
      await ref
          .read(recordProvider.notifier)
          .updateRecord(widget.record.id, updates);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 수정되었습니다'),
            backgroundColor: DesignTokens.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(recordProvider.notifier).deleteRecord(widget.record.id);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 삭제되었습니다'),
            backgroundColor: DesignTokens.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          title: '기록 수정',
          letterSpacing: 2,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: DesignTokens.error,
              ),
              onPressed: _deleteRecord,
            ),
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DesignTokens.primaryMain,
                      ),
                    )
                  : const Icon(
                      Icons.check,
                      color: DesignTokens.primaryMain,
                    ),
              onPressed: _isSaving ? null : _updateRecord,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book title and Type (read-only)
              GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '책',
                            style: AppTypography.caption.copyWith(
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.record.bookTitle,
                            style: AppTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryMain.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.record.type.label,
                        style: AppTypography.caption.copyWith(
                          color: DesignTokens.primaryMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Text input
              Text(
                '내용',
                style: AppTypography.labelMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '기록할 내용을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),

              // Tag and page
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '태그',
                          style: AppTypography.labelMedium.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: '태그',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '페이지',
                          style: AppTypography.labelMedium.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '페이지',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
