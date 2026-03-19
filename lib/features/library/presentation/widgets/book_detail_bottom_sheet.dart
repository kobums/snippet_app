import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/components/app_select.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class BookDetailBottomSheet extends ConsumerStatefulWidget {
  final UserBookDto book;

  const BookDetailBottomSheet({super.key, required this.book});

  @override
  ConsumerState<BookDetailBottomSheet> createState() =>
      _BookDetailBottomSheetState();
}

class _BookDetailBottomSheetState extends ConsumerState<BookDetailBottomSheet> {
  late BookStatus _selectedStatus;
  late int _readPage;
  TextEditingController? _pageController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.book.status;
    _readPage = widget.book.readPage;
    _pageController = TextEditingController(text: '$_readPage');
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(BookStatus status) async {
    setState(() {
      _selectedStatus = status;
    });

    try {
      await ref
          .read(bookProvider.notifier)
          .updateStatus(widget.book.id, status);

      ref.read(libraryProvider.notifier).loadAllBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태가 ${_getStatusLabel(status)}(으)로 변경되었습니다'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.7,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _selectedStatus = widget.book.status;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.7,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _updateProgress(int page) async {
    setState(() {
      _readPage = page;
      _pageController?.text = '$page';
      _isUpdating = true;
    });

    try {
      await ref
          .read(bookProvider.notifier)
          .updateProgress(widget.book.id, page);

      await ref.read(libraryProvider.notifier).loadAllBooks();

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('진행률이 업데이트되었습니다 ($page/${widget.book.totalPage})'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.7,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _readPage = widget.book.readPage;
          _pageController?.text = '${widget.book.readPage}';
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.7,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 삭제'),
        content: Text('${widget.book.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B30),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(bookProvider.notifier).deleteBook(widget.book.id);

      ref.read(libraryProvider.notifier).loadAllBooks();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book.title}이(가) 삭제되었습니다'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
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
              bottom: MediaQuery.of(context).size.height * 0.7,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(DesignTokens.space12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: DesignTokens.error,
                ),
                title: const Text(
                  '책 삭제',
                  style: TextStyle(color: DesignTokens.error),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _deleteBook();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
              // Handle bar + more button
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: DesignTokens.space12),
                          child: GestureDetector(
                            onTap: () => _showMoreMenu(context),
                            child: const Icon(
                              Icons.more_horiz,
                              color: DesignTokens.textTertiary,
                              size: DesignTokens.iconMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
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
                      // Book info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.book.coverUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 120,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.book.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.book.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.primaryMain.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getTypeLabel(widget.book.type),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: DesignTokens.primaryMain,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status
                      AppSelect<BookStatus>(
                        label: '상태',
                        value: _selectedStatus,
                        options:
                            [
                              BookStatus.waiting,
                              BookStatus.reading,
                              BookStatus.completed,
                              BookStatus.dropped,
                            ].map((status) {
                              return AppSelectOption(
                                value: status,
                                label: _getStatusLabel(status),
                                icon: _getStatusIcon(status),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateStatus(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Progress
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '진행률',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                                Text(
                                  '$_readPage / ${widget.book.totalPage} 페이지',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.book.totalPage > 0
                                    ? _readPage / widget.book.totalPage
                                    : 0,
                                minHeight: 8,
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  DesignTokens.primaryMain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: _pageController,
                              decoration: InputDecoration(
                                labelText: '읽은 페이지',
                                hintText: '0 ~ ${widget.book.totalPage}',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        '/ ${widget.book.totalPage}',
                                        style: TextStyle(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: _isUpdating
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: DesignTokens.primaryMain,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.check_circle,
                                              color: DesignTokens.primaryMain,
                                            ),
                                      onPressed: _isUpdating
                                          ? null
                                          : () {
                                              final page =
                                                  int.tryParse(
                                                    _pageController?.text ??
                                                        '0',
                                                  ) ??
                                                  0;
                                              if (page >= 0 &&
                                                  page <=
                                                      widget.book.totalPage) {
                                                _updateProgress(page);
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '0부터 ${widget.book.totalPage} 사이의 값을 입력해주세요',
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFFF3B30),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          0.7,
                                                      left: 16,
                                                      right: 16,
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                    ),
                                  ],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                              ),
                              onSubmitted: (value) {
                                final page = int.tryParse(value) ?? 0;
                                if (page >= 0 &&
                                    page <= widget.book.totalPage) {
                                  _updateProgress(page);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
