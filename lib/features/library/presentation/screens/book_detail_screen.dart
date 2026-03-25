import 'dart:ui' show ImageFilter;
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
  late String _startDate;
  late String _endDate;

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
    _startDate = widget.book.startDate;
    _endDate = widget.book.endDate;
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
        if (mounted)
          setState(() {
            _allRecords = records;
            _isLoadingRecords = false;
          });
      },
      failure: (_) {
        if (mounted)
          setState(() {
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
      if (mounted) {
        setState(() {
          _selectedType = previousType;
          _selectedStatus = widget.book.status;
        });
      }
      _showError(e);
    }
  }

  Future<void> _updateStatus(BookStatus status) async {
    setState(() => _selectedStatus = status);

    try {
      await ref
          .read(bookProvider.notifier)
          .updateStatus(widget.book.id, status);
      ref.read(libraryProvider.notifier).loadAllBooks();
    } catch (e) {
      if (mounted) {
        setState(() => _selectedStatus = widget.book.status);
      }
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
      await ref
          .read(bookProvider.notifier)
          .updateProgress(widget.book.id, page);
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Main scroll content
            CustomScrollView(
              slivers: [
                // Top padding for header
                SliverPadding(padding: EdgeInsets.only(top: topPadding + 56)),

                // Book info section
                SliverToBoxAdapter(child: _buildBookInfo()),

                // Type & Status selectors
                SliverToBoxAdapter(child: _buildSelectors()),

                // Progress & Records (not for wish)
                if (_selectedType != BookType.wish) ...[
                  SliverToBoxAdapter(child: _buildProgress()),
                  SliverToBoxAdapter(child: _buildReadingPeriod()),
                  SliverToBoxAdapter(child: _buildRecordTabs()),
                  _buildRecordsList(),
                ],

                // Bottom padding for FAB
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),

            // Floating glass header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 4,
                      right: 4,
                      bottom: 8,
                    ),
                    decoration: const BoxDecoration(
                      // color: Colors.white.withValues(alpha: 0.9),
                      // border: Border(
                      //   bottom: BorderSide(
                      //     color: Colors.black.withValues(alpha: 0.05),
                      //     width: 1,
                      //   ),
                      // ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          color: DesignTokens.textPrimary,
                        ),
                        Expanded(
                          child: Text(
                            widget.book.title,
                            style: AppTypography.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _deleteBook,
                          color: DesignTokens.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating Action Button
            if (_selectedType != BookType.wish)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _addRecord,
                  backgroundColor: DesignTokens.primaryMain,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
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
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Image.network(
              widget.book.coverUrl,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 120,
                color: Colors.grey.withValues(alpha: 0.3),
                child: Icon(
                  Icons.book,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
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
                  .where((type) {
                    // return_은 borrow이거나 이미 return_인 경우에만 표시
                    if (type == BookType.return_) {
                      return _selectedType == BookType.borrow ||
                          _selectedType == BookType.return_;
                    }
                    return true;
                  })
                  .map(
                    (type) => AppSelectOption(
                      value: type,
                      label: _getTypeLabel(type),
                      icon: _getTypeIcon(type),
                    ),
                  )
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
                options:
                    [
                          BookStatus.waiting,
                          BookStatus.reading,
                          BookStatus.completed,
                          BookStatus.dropped,
                        ]
                        .map(
                          (status) => AppSelectOption(
                            value: status,
                            label: _getStatusLabel(status),
                            icon: _getStatusIcon(status),
                          ),
                        )
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
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
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
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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

  Widget _buildReadingPeriod() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '독서 기간',
              style: AppTypography.labelMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // 시작일
            InkWell(
              onTap: () => _pickDate(isStartDate: true),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.space8,
                  horizontal: DesignTokens.space12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: DesignTokens.primaryMain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '시작',
                      style: AppTypography.bodyMedium.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _formatDate(_startDate),
                        style: AppTypography.bodyMedium.copyWith(
                          color: _startDate.isEmpty
                              ? DesignTokens.textTertiary
                              : DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_calendar,
                      size: 18,
                      color: DesignTokens.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 종료일 (완독 상태일 때만 수정 가능)
            InkWell(
              onTap: _selectedStatus == BookStatus.completed
                  ? () => _pickDate(isStartDate: false)
                  : null,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Opacity(
                opacity: _selectedStatus == BookStatus.completed ? 1.0 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.space8,
                    horizontal: DesignTokens.space12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 18,
                        color: _selectedStatus == BookStatus.completed
                            ? DesignTokens.success
                            : DesignTokens.neutral300,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '완료',
                        style: AppTypography.bodyMedium.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _formatDate(_endDate),
                          style: AppTypography.bodyMedium.copyWith(
                            color: _endDate.isEmpty
                                ? DesignTokens.textTertiary
                                : DesignTokens.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar,
                        size: 18,
                        color: _selectedStatus == BookStatus.completed
                            ? DesignTokens.textTertiary
                            : DesignTokens.neutral300,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final currentDate = isStartDate
        ? (_startDate.isNotEmpty ? DateTime.tryParse(_startDate) : null)
        : (_endDate.isNotEmpty ? DateTime.tryParse(_endDate) : null);

    final picked = await _showCustomDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      title: isStartDate ? '시작일 선택' : '완료일 선택',
    );

    if (picked != null) {
      final dateStr = picked.toIso8601String().split('T')[0];
      if (isStartDate) {
        _updateStartDate(dateStr);
      } else {
        _updateEndDate(dateStr);
      }
    }
  }

  Future<DateTime?> _showCustomDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required String title,
  }) async {
    DateTime selectedDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignTokens.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(DesignTokens.space24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.h3),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: DesignTokens.textSecondary,
                    ),
                  ],
                ),
              ),
              // Calendar
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: DesignTokens.primaryMain,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: DesignTokens.textPrimary,
                    ),
                    textTheme: const TextTheme(
                      headlineMedium: AppTypography.h3,
                      titleMedium: AppTypography.bodyMedium,
                      bodyMedium: AppTypography.bodyMedium,
                      labelLarge: AppTypography.labelLarge,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) {
                      setModalState(() => selectedDate = date);
                    },
                  ),
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(DesignTokens.space24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusMd,
                            ),
                          ),
                          side: const BorderSide(
                            color: DesignTokens.neutral300,
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: AppTypography.labelLarge.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, selectedDate),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: DesignTokens.primaryMain,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          '선택',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStartDate(String date) async {
    final previousDate = _startDate;
    setState(() => _startDate = date);

    try {
      await ref
          .read(bookProvider.notifier)
          .updateStartDate(widget.book.id, date);
      ref.read(libraryProvider.notifier).loadAllBooks();
    } catch (e) {
      if (mounted) {
        setState(() => _startDate = previousDate);
      }
      _showError(e);
    }
  }

  Future<void> _updateEndDate(String date) async {
    final previousDate = _endDate;
    setState(() => _endDate = date);

    try {
      await ref.read(bookProvider.notifier).updateEndDate(widget.book.id, date);
      ref.read(libraryProvider.notifier).loadAllBooks();
    } catch (e) {
      if (mounted) {
        setState(() => _endDate = previousDate);
      }
      _showError(e);
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '날짜 선택';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '날짜 선택';
    }
  }

  Widget _buildRecordTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('독서 기록', style: AppTypography.h3.copyWith(letterSpacing: 1)),
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
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.primaryMain
                            : DesignTokens.neutral200,
                      ),
                    ),
                    child: Text(
                      type.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : DesignTokens.textSecondary,
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
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_note,
                size: 40,
                color: Colors.black.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 6),
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
