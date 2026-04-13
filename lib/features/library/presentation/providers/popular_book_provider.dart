import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';
import 'package:snippet_app/features/library/domain/usecases/fetch_popular_books_usecase.dart';
import 'package:snippet_app/features/library/library_providers.dart';

// ============================================================================
// Period filter options
// ============================================================================
enum PopularBooksPeriod {
  oneMonth('1개월', 30),
  threeMonths('3개월', 90),
  oneYear('1년', 365);

  final String label;
  final int days;
  const PopularBooksPeriod(this.label, this.days);
}

// ============================================================================
// KDC category filter options
// ============================================================================
class KdcCategory {
  final String label;
  final String code;
  const KdcCategory(this.label, this.code);

  @override
  bool operator ==(Object other) =>
      other is KdcCategory && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

const allKdcCategory = KdcCategory('전체', '');

const kdcCategories = [
  allKdcCategory,
  KdcCategory('문학', '8'),
  KdcCategory('사회', '3'),
  KdcCategory('역사', '9'),
  KdcCategory('철학', '1'),
  KdcCategory('자연과학', '4'),
  KdcCategory('기술/공학', '5'),
  KdcCategory('예술', '6'),
  KdcCategory('언어', '7'),
  KdcCategory('총류', '0'),
];

// ============================================================================
// Age filter options
// ============================================================================
class AgeFilter {
  final String label;
  final String code;
  const AgeFilter(this.label, this.code);

  @override
  bool operator ==(Object other) => other is AgeFilter && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

const allAgeFilter = AgeFilter('전체', '');
const ageFilters = [
  allAgeFilter,
  AgeFilter('영유아', '6'),
  AgeFilter('초등', '8'),
  AgeFilter('청소년', '14'),
  AgeFilter('20대', '20'),
  AgeFilter('30대', '30'),
  AgeFilter('40대', '40'),
  AgeFilter('50대', '50'),
  AgeFilter('60대+', '60'),
];

// ============================================================================
// Gender filter options
// ============================================================================
class GenderFilter {
  final String label;
  final String code;
  const GenderFilter(this.label, this.code);

  @override
  bool operator ==(Object other) => other is GenderFilter && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

const allGenderFilter = GenderFilter('전체', '');
const genderFilters = [
  allGenderFilter,
  GenderFilter('남성', '1'),
  GenderFilter('여성', '2'),
];

// ============================================================================
// State
// ============================================================================
class PopularBooksState {
  final List<PopularBookDto> books;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final PopularBooksPeriod selectedPeriod;
  final KdcCategory selectedKdc;
  final AgeFilter selectedAge;
  final GenderFilter selectedGender;
  final AppError? error;

  const PopularBooksState({
    this.books = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedPeriod = PopularBooksPeriod.oneMonth,
    this.selectedKdc = allKdcCategory,
    this.selectedAge = allAgeFilter,
    this.selectedGender = allGenderFilter,
    this.error,
  });

  PopularBooksState copyWith({
    List<PopularBookDto>? books,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    PopularBooksPeriod? selectedPeriod,
    KdcCategory? selectedKdc,
    AgeFilter? selectedAge,
    GenderFilter? selectedGender,
    AppError? error,
    bool clearError = false,
  }) {
    return PopularBooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedKdc: selectedKdc ?? this.selectedKdc,
      selectedAge: selectedAge ?? this.selectedAge,
      selectedGender: selectedGender ?? this.selectedGender,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ============================================================================
// Notifier
// ============================================================================
class PopularBooksNotifier extends Notifier<PopularBooksState> {
  late final FetchPopularBooksUseCase _useCase;

  @override
  PopularBooksState build() {
    _useCase = ref.read(fetchPopularBooksUseCaseProvider);
    Future.microtask(() => loadBooks());
    return const PopularBooksState();
  }

  String _getStartDt() {
    final days = state.selectedPeriod.days;
    final date = DateTime.now().subtract(Duration(days: days));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getEndDt() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  PopularBooksParams _buildParams({int pageNo = 1}) {
    return PopularBooksParams(
      startDt: _getStartDt(),
      endDt: _getEndDt(),
      kdc: state.selectedKdc.code,
      age: state.selectedAge.code,
      gender: state.selectedGender.code,
      pageNo: pageNo,
    );
  }

  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true, clearError: true, currentPage: 1);

    final result = await _useCase(_buildParams());

    result.when(
      success: (books) => state = state.copyWith(
        books: books,
        isLoading: false,
        currentPage: 1,
        hasMore: books.length >= 20,
      ),
      failure: (error) => state = state.copyWith(
        isLoading: false,
        error: error,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _useCase(_buildParams(pageNo: nextPage));

    result.when(
      success: (newBooks) => state = state.copyWith(
        books: [...state.books, ...newBooks],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newBooks.length >= 20,
      ),
      failure: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  void setPeriod(PopularBooksPeriod period) {
    if (state.selectedPeriod == period) return;
    state = state.copyWith(selectedPeriod: period);
    loadBooks();
  }

  void setKdc(KdcCategory kdc) {
    if (state.selectedKdc == kdc) return;
    state = state.copyWith(selectedKdc: kdc);
    loadBooks();
  }

  void setAge(AgeFilter age) {
    if (state.selectedAge == age) return;
    state = state.copyWith(selectedAge: age);
    loadBooks();
  }

  void setGender(GenderFilter gender) {
    if (state.selectedGender == gender) return;
    state = state.copyWith(selectedGender: gender);
    loadBooks();
  }
}

final popularBooksProvider =
    NotifierProvider<PopularBooksNotifier, PopularBooksState>(
        PopularBooksNotifier.new);
