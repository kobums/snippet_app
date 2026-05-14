import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_stats_provider.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/records_providers.dart';
import 'package:snippet_app/features/records/presentation/widgets/record_card.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/reading_session_card.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';
import 'package:snippet_app/features/library/presentation/widgets/rating_dialog.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/components/app_select.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/widgets/glass_container.dart';

enum _DetailTab { snippet, diary, review, session }

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
  bool _isSaving = false; // 저장 중 뒤로가기 차단용
  bool _waitingForLibraryRefresh = false;
  late String _startDate;
  late String _endDate;

  _DetailTab _selectedDetailTab = _DetailTab.snippet;
  List<RecordDto> _allRecords = [];
  bool _isLoadingRecords = true;
  List<ReadingSessionDto> _sessions = [];
  bool _isLoadingSessions = true;

  List<RecordDto> get _records {
    final type = switch (_selectedDetailTab) {
      _DetailTab.snippet => RecordType.snippet,
      _DetailTab.diary => RecordType.diary,
      _DetailTab.review => RecordType.review,
      _DetailTab.session => RecordType.snippet,
    };
    return _allRecords.where((r) => r.type == type).toList();
  }

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
    _loadSessions();
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

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    final useCase = ref.read(fetchSessionsByBookUseCaseProvider);
    final result = await useCase(widget.book.id);
    result.when(
      success: (sessions) {
        if (mounted) {
          setState(() {
            _sessions = sessions;
            _isLoadingSessions = false;
          });
        }
      },
      failure: (_) {
        if (mounted) {
          setState(() {
            _sessions = [];
            _isLoadingSessions = false;
          });
        }
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
    final previousStatus = _selectedStatus;
    final previousEndDate = _endDate;
    final previousReadPage = _readPage;

    // 1. 낙관적 업데이트된 book 객체 생성
    final now = DateTime.now();
    final dateOnly = now.toIso8601String().split('T')[0];

    final updatedBook = widget.book.copyWith(
      status: status,
      endDate: (status == BookStatus.completed || status == BookStatus.dropped)
          ? dateOnly
          : widget.book.endDate,
      readPage: status == BookStatus.completed
          ? widget.book.totalPage
          : widget.book.readPage,
    );

    // 2. 로컬 state 즉시 업데이트 (동기)
    setState(() {
      _selectedStatus = status;
      _endDate = updatedBook.endDate;
      _readPage = updatedBook.readPage;
      _isSaving = true; // 저장 시작 - 뒤로가기 차단
    });

    // 3. 모든 provider에 즉시 전파 (동기)
    ref.read(bookProvider.notifier).updateBookLocally(updatedBook);
    ref.read(dashboardStatsProvider.notifier).updateBookLocally(updatedBook);
    ref.read(libraryProvider.notifier).updateBookLocally(updatedBook);

    // 4. 서버에 저장 (완료될 때까지 대기)
    try {
      await ref
          .read(bookProvider.notifier)
          .updateStatus(widget.book.id, status);

      // 5. 모든 provider refresh
      await ref.read(libraryProvider.notifier).loadAllBooks();
      await ref.read(dashboardStatsProvider.notifier).refreshBooks();
      await ref.read(bookProvider.notifier).refreshBooks();

      // 6. 서버 응답으로 최종 동기화 (날짜가 서버에서 설정될 수 있음)
      final syncedBook = ref
          .read(libraryProvider)
          .allBooks
          .firstWhere((b) => b.id == widget.book.id, orElse: () => widget.book);

      if (mounted) {
        setState(() {
          _endDate = syncedBook.endDate;
          _readPage = syncedBook.readPage;
          _isSaving = false; // 저장 완료 - 뒤로가기 허용
        });

        if (status == BookStatus.completed) {
          _showRatingDialog(syncedBook.rating);
        }
      }
    } catch (e) {
      // 에러 시 롤백
      if (mounted) {
        setState(() {
          _selectedStatus = previousStatus;
          _endDate = previousEndDate;
          _readPage = previousReadPage;
          _isSaving = false; // 에러 발생 - 뒤로가기 허용
        });

        // 모든 provider도 롤백
        final rolledBackBook = widget.book.copyWith(
          status: previousStatus,
          endDate: previousEndDate,
          readPage: previousReadPage,
        );
        ref.read(bookProvider.notifier).updateBookLocally(rolledBackBook);
        ref
            .read(dashboardStatsProvider.notifier)
            .updateBookLocally(rolledBackBook);
        ref.read(libraryProvider.notifier).updateBookLocally(rolledBackBook);

        _showError(e);
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
      if (mounted) setState(() => _isUpdating = false);

      if (mounted &&
          widget.book.totalPage > 0 &&
          page == widget.book.totalPage &&
          _selectedStatus != BookStatus.completed) {
        await _updateStatus(BookStatus.completed);
      }
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
    if (_selectedDetailTab == _DetailTab.snippet) {
      final imagePath = await context.push<String>(AppRoutes.camera);
      if (imagePath != null) _loadRecords();
      return;
    }

    final recordType = switch (_selectedDetailTab) {
      _DetailTab.diary => RecordType.diary,
      _DetailTab.review => RecordType.review,
      _ => RecordType.diary,
    };

    final result = await context.push<bool>(
      AppRoutes.addRecord,
      extra: AddRecordScreenParams(
        books: [widget.book],
        initialType: recordType,
      ),
    );
    if (result == true) _loadRecords();
  }

  void _showRatingDialog(int? currentRating) {
    RatingDialog.show(
      context,
      bookTitle: widget.book.title,
      initialRating: currentRating,
      onRatingSubmit: (rating) {
        if (rating != null) {
          ref.read(bookProvider.notifier).updateRating(widget.book.id, rating);
          ref.read(libraryProvider.notifier).updateBookLocally(
            widget.book.copyWith(rating: rating),
          );
        }
      },
    );
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

    ref.listen(sessionJustCompletedProvider, (_, completed) {
      if (!completed || !mounted) return;
      ref.read(sessionJustCompletedProvider.notifier).reset();
      setState(() {
        _selectedDetailTab = _DetailTab.session;
        _waitingForLibraryRefresh = true;
      });
      _loadSessions();
    });

    ref.listen(libraryProvider, (prev, next) {
      if (!_waitingForLibraryRefresh) return;
      if (next.isLoading) return;
      _waitingForLibraryRefresh = false;
      final updated = next.allBooks
          .where((b) => b.id == widget.book.id)
          .firstOrNull;
      if (updated != null && mounted) {
        setState(() {
          _readPage = updated.readPage;
          _pageController?.text = '$_readPage';
        });
      }
    });

    return PopScope(
      canPop: !_isSaving, // 저장 중일 때는 뒤로가기 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSaving) {
          // 저장 중이라는 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('저장 중입니다. 잠시만 기다려주세요.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Material(
        color: context.colors.surface,
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
                    if (_selectedType == BookType.borrow)
                      SliverToBoxAdapter(child: _buildReturnDate()),
                    if (_selectedStatus == BookStatus.completed)
                      SliverToBoxAdapter(child: _buildRating()),
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
                            color: context.colors.textPrimary,
                          ),
                          Expanded(
                            child: Text(
                              widget.book.title,
                              style: AppTypography.h3.copyWith(
                                color: context.colors.textPrimary,
                              ),
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
              if (_selectedType != BookType.wish &&
                  _selectedDetailTab != _DetailTab.session)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _addRecord,
                    backgroundColor: context.colors.primary,
                    child: Icon(
                      _selectedDetailTab == _DetailTab.snippet
                          ? Icons.camera_alt
                          : Icons.add,
                      color: context.colors.surface,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ), // Material의 끝
    ); // PopScope의 끝
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
                color: context.colors.border,
                child: Icon(Icons.book, color: context.colors.iconSecondary),
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
                  style: AppTypography.h3.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.book.author,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
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
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  '$_readPage / ${widget.book.totalPage} 페이지',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textTertiary,
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
                backgroundColor: context.colors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primary,
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
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _isUpdating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colors.primary,
                              ),
                            )
                          : Icon(
                              Icons.check_circle,
                              color: context.colors.primary,
                            ),
                      onPressed: _isUpdating ? null : _submitProgress,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                filled: true,
                fillColor: context.colors.inputFill,
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value) ?? 0;
                if (page >= 0 && page <= widget.book.totalPage) {
                  _updateProgress(page);
                  FocusScope.of(context).unfocus();
                }
              },
            ),
            if (_selectedStatus == BookStatus.reading) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final currentBook = widget.book.copyWith(
                      readPage: _readPage,
                    );
                    context.push(AppRoutes.activeSession, extra: currentBook);
                  },
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: context.colors.surface,
                  ),
                  label: Text(
                    '독서 시작',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: DesignTokens.fontMedium,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                    ),
                    textStyle: AppTypography.bodyMedium.copyWith(
                      fontWeight: DesignTokens.fontMedium,
                    ),
                  ),
                ),
              ),
            ],
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
                color: context.colors.textSecondary,
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
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '시작',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _formatDate(_startDate),
                        style: AppTypography.bodyMedium.copyWith(
                          color: _startDate.isEmpty
                              ? context.colors.textTertiary
                              : context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar,
                      size: 18,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedStatus == BookStatus.completed) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(isStartDate: false),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.space8,
                    horizontal: DesignTokens.space12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flag,
                        size: 18,
                        color: DesignTokens.success,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '완료',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _formatDate(_endDate),
                          style: AppTypography.bodyMedium.copyWith(
                            color: _endDate.isEmpty
                                ? context.colors.textTertiary
                                : context.colors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar,
                        size: 18,
                        color: context.colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
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
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXxs),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(DesignTokens.space24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h3.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
              // Calendar
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: context.colors.primary,
                      onPrimary: Colors.white,
                      surface: context.colors.surface,
                      onSurface: context.colors.textPrimary,
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
                  color: context.colors.surface,
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
                          side: BorderSide(color: context.colors.border),
                        ),
                        child: Text(
                          '취소',
                          style: AppTypography.labelLarge.copyWith(
                            color: context.colors.textSecondary,
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
                          backgroundColor: context.colors.primary,
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

    // 1. 낙관적 업데이트된 book 객체 생성
    final updatedBook = widget.book.copyWith(startDate: date);

    // 2. 로컬 state 즉시 업데이트
    setState(() {
      _startDate = date;
      _isSaving = true; // 저장 시작 - 뒤로가기 차단
    });

    // 3. bookProvider, libraryProvider는 즉시 전파 (낙관적)
    ref.read(bookProvider.notifier).updateBookLocally(updatedBook);
    ref.read(libraryProvider.notifier).updateBookLocally(updatedBook);

    // 4. 서버에 저장 (완료될 때까지 대기)
    try {
      await ref
          .read(bookProvider.notifier)
          .updateStartDate(widget.book.id, date);

      // 5. 모든 provider refresh
      await ref.read(libraryProvider.notifier).loadAllBooks();
      await ref.read(dashboardStatsProvider.notifier).refreshBooks();
      await ref.read(bookProvider.notifier).refreshBooks();

      if (mounted) {
        setState(() => _isSaving = false); // 저장 완료 - 뒤로가기 허용
      }
    } catch (e) {
      // 에러 시 롤백
      if (mounted) {
        setState(() {
          _startDate = previousDate;
          _isSaving = false; // 에러 발생 - 뒤로가기 허용
        });
        ref
            .read(bookProvider.notifier)
            .updateBookLocally(widget.book.copyWith(startDate: previousDate));
        ref
            .read(libraryProvider.notifier)
            .updateBookLocally(widget.book.copyWith(startDate: previousDate));
        await ref.read(dashboardStatsProvider.notifier).refreshBooks();
        _showError(e);
      }
    }
  }

  Future<void> _updateEndDate(String date) async {
    final previousDate = _endDate;

    // 1. 낙관적 업데이트된 book 객체 생성
    final updatedBook = widget.book.copyWith(endDate: date);

    // 2. 로컬 state 즉시 업데이트
    setState(() {
      _endDate = date;
      _isSaving = true; // 저장 시작 - 뒤로가기 차단
    });

    // 3. bookProvider, libraryProvider는 즉시 전파 (낙관적)
    ref.read(bookProvider.notifier).updateBookLocally(updatedBook);
    ref.read(libraryProvider.notifier).updateBookLocally(updatedBook);

    // 4. 서버에 저장 (완료될 때까지 대기 - 날짜 변경은 덜 빈번하므로 acceptable)
    try {
      await ref.read(bookProvider.notifier).updateEndDate(widget.book.id, date);

      // 5. 모든 provider refresh
      await ref.read(libraryProvider.notifier).loadAllBooks();
      await ref.read(dashboardStatsProvider.notifier).refreshBooks();
      await ref.read(bookProvider.notifier).refreshBooks();

      if (mounted) {
        setState(() => _isSaving = false); // 저장 완료 - 뒤로가기 허용
      }
    } catch (e) {
      // 에러 시 롤백
      if (mounted) {
        setState(() {
          _endDate = previousDate;
          _isSaving = false; // 에러 발생 - 뒤로가기 허용
        });
        ref
            .read(bookProvider.notifier)
            .updateBookLocally(widget.book.copyWith(endDate: previousDate));
        ref
            .read(libraryProvider.notifier)
            .updateBookLocally(widget.book.copyWith(endDate: previousDate));
        await ref.read(dashboardStatsProvider.notifier).refreshBooks();
        _showError(e);
      }
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

  Widget _buildReturnDate() {
    final returnDateStr = widget.book.returnDate;
    final returnDate = returnDateStr != null && returnDateStr.isNotEmpty
        ? DateTime.tryParse(returnDateStr)
        : null;

    String dDayText = '';
    Color dDayColor = DesignTokens.neutral500;

    if (returnDate != null) {
      final today = DateTime.now();
      final diff = returnDate.difference(DateTime(today.year, today.month, today.day)).inDays;
      if (diff < 0) {
        dDayText = '연체 ${-diff}일';
        dDayColor = DesignTokens.error;
      } else if (diff == 0) {
        dDayText = '오늘 반납';
        dDayColor = DesignTokens.warning;
      } else if (diff <= 3) {
        dDayText = 'D-$diff';
        dDayColor = DesignTokens.warning;
      } else {
        dDayText = 'D-$diff';
        dDayColor = DesignTokens.success;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '반납 기한',
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (dDayText.isNotEmpty) ...[
                  const SizedBox(width: DesignTokens.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: dDayColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      border: Border.all(color: dDayColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      dDayText,
                      style: AppTypography.captionSmall.copyWith(
                        color: dDayColor,
                        fontWeight: DesignTokens.fontMedium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            InkWell(
              onTap: () => _pickReturnDate(),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.space8,
                  horizontal: DesignTokens.space12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: returnDate != null && returnDate.difference(DateTime.now()).inDays < 0
                          ? DesignTokens.error
                          : context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        returnDate != null
                            ? _formatDate(returnDateStr!)
                            : '반납 기한을 설정하세요',
                        style: AppTypography.bodyMedium.copyWith(
                          color: returnDate != null
                              ? context.colors.textPrimary
                              : context.colors.textTertiary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar,
                      size: 18,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReturnDate() async {
    final current = widget.book.returnDate != null && widget.book.returnDate!.isNotEmpty
        ? DateTime.tryParse(widget.book.returnDate!)
        : null;

    final picked = await _showCustomDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 14)),
      title: '반납 기한 선택',
    );

    if (picked != null && mounted) {
      final dateStr = picked.toIso8601String().split('T')[0];
      await ref.read(bookProvider.notifier).updateReturnDate(widget.book.id, dateStr);
      await ref.read(libraryProvider.notifier).loadAllBooks();
    }
  }

  Widget _buildRating() {
    final currentRating = widget.book.rating;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GlassContainer(
        child: Row(
          children: [
            Text(
              '별점',
              style: AppTypography.labelMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: DesignTokens.space16),
            Expanded(
              child: Row(
                children: List.generate(5, (i) {
                  final star = i + 1;
                  final filled = currentRating != null && star <= currentRating;
                  return GestureDetector(
                    onTap: () => _showRatingDialog(currentRating),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 28,
                      color: filled ? const Color(0xFFFFB800) : context.colors.border,
                    ),
                  );
                }),
              ),
            ),
            TextButton(
              onPressed: () => _showRatingDialog(currentRating),
              child: Text(
                currentRating != null ? '수정' : '평가하기',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTabs() {
    const tabLabels = {
      _DetailTab.snippet: '스니펫',
      _DetailTab.diary: '독서일기',
      _DetailTab.review: '리뷰',
      _DetailTab.session: '독서세션',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '독서 기록',
            style: AppTypography.h3.copyWith(
              color: context.colors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _DetailTab.values.map((tab) {
                final isSelected = tab == _selectedDetailTab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDetailTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space16,
                        vertical: DesignTokens.space8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusFull,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.border,
                        ),
                      ),
                      child: Text(
                        tabLabels[tab]!,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? context.colors.surface
                              : context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_selectedDetailTab == _DetailTab.session) {
      return _buildSessionsList();
    }

    if (_isLoadingRecords) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final tabLabel = switch (_selectedDetailTab) {
      _DetailTab.snippet => '스니펫',
      _DetailTab.diary => '독서일기',
      _DetailTab.review => '리뷰',
      _DetailTab.session => '',
    };

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
                color: context.colors.textDisabled,
              ),
              const SizedBox(height: 6),
              Text(
                '아직 $tabLabel이(가) 없습니다',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textTertiary,
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

  Widget _buildSessionsList() {
    if (_isLoadingSessions) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off_outlined,
                size: 40,
                color: context.colors.textDisabled,
              ),
              const SizedBox(height: 6),
              Text(
                '아직 독서 세션이 없습니다',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textTertiary,
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
          (context, index) => ReadingSessionCard(session: _sessions[index]),
          childCount: _sessions.length,
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
