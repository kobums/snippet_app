import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_book_header.dart';
import 'package:snippet_app/components/app_select.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class AddRecordScreenParams {
  final List<UserBookDto> books;
  final RecordType? initialType;
  final String? initialText;

  const AddRecordScreenParams({
    required this.books,
    this.initialType,
    this.initialText,
  });
}

class AddRecordScreen extends ConsumerStatefulWidget {
  final List<UserBookDto> books;
  final RecordType? initialType;
  final String? initialText;

  const AddRecordScreen({
    super.key,
    required this.books,
    this.initialType,
    this.initialText,
  });

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  late RecordType _selectedType;
  UserBookDto? _selectedBook;
  final _textController = TextEditingController();
  final _tagController = TextEditingController();
  final _pageController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? RecordType.snippet;
    if (widget.books.isNotEmpty) {
      _selectedBook = widget.books.first;
    }
    // OCR 결과 텍스트로 프리필
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _tagController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('책을 선택해주세요'),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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

    final data = RecordAddRequestDto(
      type: _selectedType,
      text: _textController.text.trim(),
      tag: _tagController.text.trim().isEmpty
          ? null
          : _tagController.text.trim(),
      relatedPage: _pageController.text.trim().isEmpty
          ? null
          : int.tryParse(_pageController.text.trim()),
    );

    try {
      await ref
          .read(recordProvider.notifier)
          .addRecord(_selectedBook!.id, data);

      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 추가되었습니다'),
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

  @override
  Widget build(BuildContext context) {
    final singleBook = widget.books.length == 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppAppBar(
          title: '${_selectedType.label} 추가',
          letterSpacing: 2,
          actions: [
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
                  : Icon(Icons.check, color: context.colors.primary),
              onPressed: _isSaving ? null : _addRecord,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book info
              if (_selectedBook != null)
                AppBookHeader(
                  title: _selectedBook!.title,
                  author: _selectedBook!.author,
                  coverUrl: _selectedBook!.coverUrl,
                  badgeText: _selectedType.label,
                ),
              if (!singleBook) ...[
                const SizedBox(height: DesignTokens.space12),
                DropdownButtonFormField<UserBookDto>(
                  initialValue: _selectedBook,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '책 변경',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    filled: true,
                    fillColor: context.colors.inputFill,
                  ),
                  items: widget.books.map((book) {
                    return DropdownMenuItem(
                      value: book,
                      child: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (book) {
                    setState(() => _selectedBook = book);
                  },
                ),
              ],
              const SizedBox(height: 16),

              // // Record type selector
              // AppSelect<RecordType>(
              //   label: '유형',
              //   dense: true,
              //   value: _selectedType,
              //   options: RecordType.values.map((type) {
              //     return AppSelectOption(
              //       value: type,
              //       label: type.label,
              //       icon: _getRecordTypeIcon(type),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() => _selectedType = value);
              //     }
              //   },
              // ),
              // const SizedBox(height: 16),

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

  IconData _getRecordTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.snippet:
        return Icons.format_quote;
      case RecordType.diary:
        return Icons.edit_note;
      case RecordType.review:
        return Icons.rate_review;
    }
  }
}
