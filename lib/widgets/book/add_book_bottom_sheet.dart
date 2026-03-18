import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/design_tokens.dart';
import '../../models/book_search.dart';
import '../../models/user_book.dart';
import '../../providers/book_provider.dart';
import '../../components/app_button.dart';
import '../../components/app_select.dart';
import '../glass_container.dart';

class AddBookBottomSheet extends ConsumerStatefulWidget {
  final BookSearchDto book;

  const AddBookBottomSheet({super.key, required this.book});

  @override
  ConsumerState<AddBookBottomSheet> createState() => _AddBookBottomSheetState();
}

class _AddBookBottomSheetState extends ConsumerState<AddBookBottomSheet> {
  BookType _selectedType = BookType.have;
  BookStatus _selectedStatus = BookStatus.waiting;
  int _totalPages = 0;
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    _totalPages = widget.book.totalPage ?? 0;
  }

  Future<void> _addBook() async {
    final now = DateTime.now().toIso8601String();

    // Create book data
    final bookData = {
      'title': widget.book.title,
      'author': widget.book.author,
      'publisher': widget.book.publisher,
      'pubDate': widget.book.pubDate,
      'isbn': widget.book.isbn,
      'coverUrl': widget.book.coverUrl,
      'totalPage': _totalPages,
      'type': _selectedType.toJson(),
      'status': _selectedStatus.toJson(),
      'readPage': 0,
      'startDate': _startDate?.toIso8601String() ?? now,
      'endDate': now,
      'createDate': now,
    };

    // Optimistic update
    final bookNotifier = ref.read(bookProvider.notifier);
    final tempBook = UserBookDto(
      id: 0, // Will be replaced
      bookId: 0,
      title: widget.book.title,
      author: widget.book.author,
      coverUrl: widget.book.coverUrl,
      type: _selectedType,
      status: _selectedStatus,
      readPage: 0,
      totalPage: _totalPages,
      createDate: now,
      startDate: _startDate?.toIso8601String() ?? now,
      endDate: now,
    );

    final tempId = bookNotifier.addBookLocally(tempBook);

    // Close bottom sheet immediately
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.book.title} 추가 중...'),
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
      final api = ref.read(userBookApiProvider);
      final realId = await api.addUserBook(bookData);

      // Replace temp ID with real ID
      bookNotifier.updateBookId(tempId, realId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book.title} 추가 완료!'),
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
      // Rollback on error
      bookNotifier.removeBookLocally(tempId);

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
                        '책 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Book info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.book.coverUrl,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.book.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.book.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Type selection
                      AppSelect<BookType>(
                        label: '분류',
                        value: _selectedType,
                        options: BookType.values.map((type) {
                          return AppSelectOption(
                            value: type,
                            label: _getTypeLabel(type),
                            icon: _getTypeIcon(type),
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

                      // Status selection (if not wishlist)
                      if (_selectedType != BookType.wish)
                        AppSelect<BookStatus>(
                          label: '상태',
                          value: _selectedStatus,
                          options:
                              [
                                BookStatus.waiting,
                                BookStatus.reading,
                                BookStatus.completed,
                              ].map((status) {
                                return AppSelectOption(
                                  value: status,
                                  label: _getStatusLabel(status),
                                  icon: _getStatusIcon(status),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 12),

                      // Total pages
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '총 페이지',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '페이지 수',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                              ),
                              controller: TextEditingController(
                                text: '$_totalPages',
                              ),
                              onChanged: (value) {
                                _totalPages = int.tryParse(value) ?? 0;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add button
                      AppButton(
                        text: '추가하기',
                        onPressed: _addBook,
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

  String _getTypeLabel(BookType type) {
    switch (type) {
      case BookType.wish:
        return '위시리스트';
      case BookType.have:
        return '소장';
      case BookType.borrow:
        return '대여';
      case BookType.return_:
        return '반납';
    }
  }

  IconData _getTypeIcon(BookType type) {
    switch (type) {
      case BookType.wish:
        return Icons.favorite_outline;
      case BookType.have:
        return Icons.book;
      case BookType.borrow:
        return Icons.auto_stories;
      case BookType.return_:
        return Icons.keyboard_return;
    }
  }

  String _getStatusLabel(BookStatus status) {
    switch (status) {
      case BookStatus.none:
        return '없음';
      case BookStatus.waiting:
        return '읽을 예정';
      case BookStatus.reading:
        return '읽는 중';
      case BookStatus.completed:
        return '완독';
      case BookStatus.dropped:
        return '중단';
    }
  }

  IconData _getStatusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.none:
        return Icons.remove_circle_outline;
      case BookStatus.waiting:
        return Icons.schedule;
      case BookStatus.reading:
        return Icons.menu_book;
      case BookStatus.completed:
        return Icons.check_circle_outline;
      case BookStatus.dropped:
        return Icons.cancel_outlined;
    }
  }
}
