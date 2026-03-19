import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/components/app_select.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class AddRecordBottomSheet extends ConsumerStatefulWidget {
  final List<UserBookDto> books;
  final RecordType? initialType;

  const AddRecordBottomSheet({
    super.key,
    required this.books,
    this.initialType,
  });

  @override
  ConsumerState<AddRecordBottomSheet> createState() =>
      _AddRecordBottomSheetState();
}

class _AddRecordBottomSheetState extends ConsumerState<AddRecordBottomSheet> {
  late RecordType _selectedType;
  UserBookDto? _selectedBook;
  final _textController = TextEditingController();
  final _tagController = TextEditingController();
  final _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? RecordType.snippet;
    if (widget.books.isNotEmpty) {
      _selectedBook = widget.books.first;
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
        SnackBar(
          content: const Text('책을 선택해주세요'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.7,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('내용을 입력해주세요'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.7,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

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

    // Close bottom sheet immediately
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('기록 추가 중...'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // Call API in background
    try {
      await ref
          .read(recordProvider.notifier)
          .addRecord(_selectedBook!.id, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('기록이 추가되었습니다'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: DesignTokens.bgPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar (고정 영역)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 스크롤 가능한 영역
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const Text(
                        '기록 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Type selection
                      AppSelect<RecordType>(
                        label: '유형',
                        value: _selectedType,
                        options: RecordType.values.map((type) {
                          return AppSelectOption(
                            value: type,
                            label: type.label,
                            icon: _getRecordTypeIcon(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Book selection
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '책',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<UserBookDto>(
                              initialValue: _selectedBook,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
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
                                setState(() {
                                  _selectedBook = book;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Text input
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '내용',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _textController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: '기록할 내용을 입력하세요',
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
                      const SizedBox(height: 12),

                      // Tag and page
                      Row(
                        children: [
                          // Tag
                          Expanded(
                            child: GlassContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '태그',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _tagController,
                                    decoration: InputDecoration(
                                      hintText: '태그',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Page
                          Expanded(
                            child: GlassContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '페이지',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _pageController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '페이지',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Add button
                      AppButton(
                        text: '추가하기',
                        onPressed: _addRecord,
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.large,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); // GestureDetector 닫기
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
