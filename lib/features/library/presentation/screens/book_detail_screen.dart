import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/records_providers.dart';
import 'package:snippet_app/features/records/presentation/widgets/record_card.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_select.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final UserBookDto book;

  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  late BookType _selectedType;
  late BookStatus _selectedStatus;
  late int _readPage;
  TextEditingController? _pageController;
  bool _isUpdating = false;

  RecordType _selectedRecordType = RecordType.snippet;
  List<RecordDto> _allRecords = [];
  bool _isLoadingRecords = true;

  List<RecordDto> get _records =>
      _allRecords.where((r) => r.type == _selectedRecordType).toList();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.book.type;
    _selectedStatus = widget.book.status;
    _readPage = widget.book.readPage;
    _pageController = TextEditingController(text: '$_readPage');
    _loadRecords();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoadingRecords = true);

    final useCase = ref.read(fetchRecordsByBookUseCaseProvider);
    final result = await useCase(widget.book.bookId);

    result.when(
      success: (records) {
        if (mounted) setState(() {
          _allRecords = records;
          _isLoadingRecords = false;
        });
      },
      failure: (_) {
        if (mounted) setState(() {
          _allRecords = [];
          _isLoadingRecords = false;
        });
      },
    );
  }

  Future<void> _updateType(BookType type) async {
    final previousType = _selectedType;
    setState(() {
      _selectedType = type;
      if (type == BookType.wish) {
        _selectedStatus = BookStatus.none;
      } else if (_selectedStatus == BookStatus.none) {
        _selectedStatus = BookStatus.waiting;
      }
    });

    try {
      await ref.read(bookProvider.notifier).updateType(widget.book.id, type);
      ref.read(libraryProvider.notifier).loadAllBooks();
    } catch (e) {
      setState(() {
        _selectedType = previousType;
        _selectedStatus = widget.book.status;
      });
      _showError(e);
    }
  }

  Future<void> _updateStatus(BookStatus status) async {
    setState(() => _selectedStatus = status);

    try {
      await ref.read(bookProvider.notifier).updateStatus(widget.book.id, status);
      ref.read(libraryProvider.notifier).loadAllBooks();
    } catch (e) {
      setState(() => _selectedStatus = widget.book.status);
      _showError(e);
    }
  }

  Future<void> _updateProgress(int page) async {
    setState(() {
      _readPage = page;
      _pageController?.text = '$page';
      _isUpdating = true;
    });

    try {
      await ref.read(bookProvider.notifier).updateProgress(widget.book.id, page);
      await ref.read(libraryProvider.notifier).loadAllBooks();
      if (mounted) setState(() => _isUpdating = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _readPage = widget.book.readPage;
          _pageController?.text = '${widget.book.readPage}';
          _isUpdating = false;
        });
      }
      _showError(e);
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
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(bookProvider.notifier).deleteBook(widget.book.id);
      ref.read(libraryProvider.notifier).loadAllBooks();
      if (mounted) context.pop();
    } catch (e) {
      _showError(e);
    }
  }

  void _addRecord() async {
    final result = await context.push<bool>(
      AppRoutes.addRecord,
      extra: AddRecordScreenParams(
        books: [widget.book],
        initialType: _selectedRecordType,
      ),
    );
    if (result == true) _loadRecords();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: DesignTokens.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          title: widget.book.title,
          letterSpacing: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: DesignTokens.error),
              onPressed: _deleteBook,
            ),
          ],
        ),
        floatingActionButton: _selectedType != BookType.wish
            ? FloatingActionButton(
                onPressed: _addRecord,
                backgroundColor: DesignTokens.primaryMain,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: CustomScrollView(
          slivers: [
            // Book info section
            SliverToBoxAdapter(child: _buildBookInfo()),

            // Type & Status selectors
            SliverToBoxAdapter(child: _buildSelectors()),

            // Progress & Records (not for wish)
            if (_selectedType != BookType.wish) ...[
              SliverToBoxAdapter(child: _buildProgress()),
              SliverToBoxAdapter(child: _buildRecordTabs()),
              _buildRecordsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.book.coverUrl,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 120,
                color: Colors.grey.withValues(alpha: 0.3),
                child: Icon(Icons.book, color: Colors.grey.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: AppTypography.h3,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.book.author,
                  style: AppTypography.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: AppSelect<BookType>(
              label: '분류',
              dense: true,
              value: _selectedType,
              options: BookType.values
                  .where((type) => type != BookType.return_)
                  .map((type) => AppSelectOption(
                        value: type,
                        label: _getTypeLabel(type),
                        icon: _getTypeIcon(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) _updateType(value);
              },
            ),
          ),
          if (_selectedType != BookType.wish) ...[
            const SizedBox(width: 12),
            Expanded(
              child: AppSelect<BookStatus>(
                label: '상태',
                dense: true,
                value: _selectedStatus,
                options: [
                  BookStatus.waiting,
                  BookStatus.reading,
                  BookStatus.completed,
                  BookStatus.dropped,
                ]
                    .map((status) => AppSelectOption(
                          value: status,
                          label: _getStatusLabel(status),
                          icon: _getStatusIcon(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _updateStatus(value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행률',
                  style: AppTypography.labelMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                Text(
                  '$_readPage / ${widget.book.totalPage} 페이지',
                  style: AppTypography.bodySmall.copyWith(
                    color: DesignTokens.textTertiary,
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
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
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
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '/ ${widget.book.totalPage}',
                        style: AppTypography.bodySmall.copyWith(
                          color: DesignTokens.textTertiary,
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
                      onPressed: _isUpdating ? null : _submitProgress,
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
                if (page >= 0 && page <= widget.book.totalPage) {
                  _updateProgress(page);
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitProgress() {
    final page = int.tryParse(_pageController?.text ?? '0') ?? 0;
    if (page >= 0 && page <= widget.book.totalPage) {
      _updateProgress(page);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('0부터 ${widget.book.totalPage} 사이의 값을 입력해주세요'),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildRecordTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '독서 기록',
            style: AppTypography.h3.copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            children: RecordType.values.map((type) {
              final isSelected = type == _selectedRecordType;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedRecordType = type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                      vertical: DesignTokens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.primaryMain
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.primaryMain
                            : DesignTokens.neutral200,
                      ),
                    ),
                    child: Text(
                      type.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? Colors.white : DesignTokens.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_isLoadingRecords) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_records.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                size: 48,
                color: Colors.black.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 12),
              Text(
                '아직 ${_selectedRecordType.label}이(가) 없습니다',
                style: AppTypography.bodyMedium.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => RecordCard(record: _records[index]),
          childCount: _records.length,
        ),
      ),
    );
  }

  // Helper methods

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
