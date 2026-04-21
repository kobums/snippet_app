import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/library/presentation/providers/popular_book_provider.dart';
import 'package:snippet_app/features/library/presentation/widgets/popular_book_card.dart';
import 'package:snippet_app/features/library/presentation/widgets/popular_book_filter_bar.dart';

class PopularBooksScreen extends ConsumerStatefulWidget {
  const PopularBooksScreen({super.key});

  @override
  ConsumerState<PopularBooksScreen> createState() =>
      _PopularBooksScreenState();
}

class _PopularBooksScreenState extends ConsumerState<PopularBooksScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(popularBooksProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(popularBooksProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          AppAppBar.sliver(
            title: '인기 도서',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
        ],
        body: Column(
          children: [
            const PopularBookFilterBar(),
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PopularBooksState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.books.isEmpty) {
      return _buildError(state.error!.message);
    }

    if (state.books.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(popularBooksProvider.notifier).loadBooks(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space12),
        itemCount: state.books.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.books.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PopularBookCard(book: state.books[index]);
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up_rounded,
              size: 64, color: DesignTokens.neutral300),
          const SizedBox(height: 16),
          Text(
            '인기 도서 정보를 불러올 수 없습니다',
            style: AppTypography.bodyMedium
                .copyWith(color: DesignTokens.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: DesignTokens.neutral400),
          const SizedBox(height: 12),
          Text(
            '오류가 발생했습니다',
            style: AppTypography.bodyMedium
                .copyWith(color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTypography.captionSmall
                .copyWith(color: DesignTokens.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () =>
                ref.read(popularBooksProvider.notifier).loadBooks(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
