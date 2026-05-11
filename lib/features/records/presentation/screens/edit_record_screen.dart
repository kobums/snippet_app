import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_book_header.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/records/presentation/widgets/notes_export_section.dart';

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

  void _showExportModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.space24,
            DesignTokens.space8,
            DesignTokens.space24,
            DesignTokens.space32,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: DesignTokens.space20),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              NotesExportSection(record: widget.record),
            ],
          ),
        ),
      ),
    );
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
        backgroundColor: context.colors.surface,
        appBar: AppAppBar(
          title: '기록 수정',
          letterSpacing: 2,
          actions: [
            IconButton(
              icon: Icon(Icons.download_outlined, color: context.colors.textSecondary),
              tooltip: '이미지로 내보내기',
              onPressed: _showExportModal,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: DesignTokens.error,
              ),
              onPressed: _deleteRecord,
            ),
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.primary,
                      ),
                    )
                  : Icon(
                      Icons.check,
                      color: context.colors.primary,
                    ),
              onPressed: _isSaving ? null : _updateRecord,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book header (read-only)
              AppBookHeader(
                title: widget.record.bookTitle,
                author: widget.record.bookAuthor,
                coverUrl: widget.record.bookCoverUrl,
                badgeText: widget.record.type.label,
              ),
              const SizedBox(height: 16),

              // Text input
              Text(
                '내용',
                style: AppTypography.labelMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '기록할 내용을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: '태그',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            ),
                            filled: true,
                            fillColor: context.colors.inputFill,
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
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '페이지',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            ),
                            filled: true,
                            fillColor: context.colors.inputFill,
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
