import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_stats_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/reading_session/presentation/providers/reading_session_provider.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_section.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_widget.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';

class SessionCompleteScreen extends ConsumerStatefulWidget {
  const SessionCompleteScreen({super.key});

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends ConsumerState<SessionCompleteScreen> {
  late final TextEditingController _endPageController;
  String? _pageError;

  @override
  void initState() {
    super.initState();
    final state = ref.read(readingSessionProvider);
    _endPageController = TextEditingController(
      text: state.startPage > 0 ? state.startPage.toString() : '',
    );
  }

  @override
  void dispose() {
    _endPageController.dispose();
    super.dispose();
  }

  int? get _parsedEndPage => int.tryParse(_endPageController.text);

  int _previewPagesRead(ReadingSessionState state) {
    final end = _parsedEndPage ?? state.startPage;
    return (end - state.startPage).clamp(0, 99999);
  }

  String _previewPace(ReadingSessionState state) {
    final pages = _previewPagesRead(state);
    if (pages == 0) return '--';
    final spp = state.elapsedSeconds / pages;
    return '${(spp / 60).toStringAsFixed(1)} min/p';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingSessionProvider);

    if (state.status == SessionStatus.saving) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == SessionStatus.completing) {
      return _buildEndPageInput(context, state);
    }

    return _buildResult(context, state);
  }

  // ─── Phase 1: 종료 페이지 입력 ──────────────────────────────────────────────

  Widget _buildEndPageInput(BuildContext context, ReadingSessionState state) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard(context);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: DesignTokens.textPrimary),
              onPressed: () => _confirmDiscard(context),
            ),
            title: const Text(
              '독서 완료',
              style: TextStyle(
                fontSize: DesignTokens.fontSize18,
                fontWeight: DesignTokens.fontMedium,
                color: DesignTokens.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              DesignTokens.space24,
              DesignTokens.space24,
              DesignTokens.space24,
              DesignTokens.space24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.book != null)
                  Text(
                    state.book!.title,
                    style: const TextStyle(
                      fontSize: DesignTokens.fontSize20,
                      fontWeight: DesignTokens.fontMedium,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                const SizedBox(height: DesignTokens.space24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space32,
                      vertical: DesignTokens.space20,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryMain.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.formattedTime,
                          style: const TextStyle(
                            fontSize: DesignTokens.fontSize40,
                            fontWeight: FontWeight.w300,
                            color: DesignTokens.primaryMain,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.space4),
                        const Text(
                          '독서 시간',
                          style: TextStyle(
                            fontSize: DesignTokens.fontSize12,
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space32),
                const Text(
                  '어디까지 읽으셨나요?',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSize18,
                    fontWeight: DesignTokens.fontMedium,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  '시작 페이지: ${state.startPage}p',
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSize14,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                StatefulBuilder(
                  builder: (context, setLocal) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _endPageController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: DesignTokens.fontSize32,
                          fontWeight: FontWeight.w300,
                          color: DesignTokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          errorText: _pageError,
                          hintText: state.startPage.toString(),
                          suffixText: '페이지',
                          suffixStyle: const TextStyle(
                            fontSize: DesignTokens.fontSize16,
                            color: DesignTokens.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusMd),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusMd),
                            borderSide: const BorderSide(
                              color: DesignTokens.primaryMain,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (_) => setLocal(() {}),
                      ),
                      const SizedBox(height: DesignTokens.space12),
                      AnimatedOpacity(
                        opacity: (_previewPagesRead(state) > 0) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space16,
                            vertical: DesignTokens.space12,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.neutral100,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PreviewChip(
                                label: '읽은 페이지',
                                value: '${_previewPagesRead(state)}p',
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                color: DesignTokens.neutral300,
                              ),
                              _PreviewChip(
                                label: '페이스',
                                value: _previewPace(state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.space32),
                AppButton(
                  text: '기록 저장',
                  onPressed: () => _saveSession(context, state),
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
                const SizedBox(height: DesignTokens.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Phase 2: 결과 화면 ─────────────────────────────────────────────────────

  Widget _buildResult(BuildContext context, ReadingSessionState state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: DesignTokens.textPrimary),
          onPressed: () => _exitSession(context),
        ),
        title: const Text(
          '독서 완료',
          style: TextStyle(
            fontSize: DesignTokens.fontSize18,
            fontWeight: DesignTokens.fontMedium,
            color: DesignTokens.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(state),
            const SizedBox(height: DesignTokens.space32),
            ShareCardSection(
              initialData: ShareCardData.fromSessionState(state),
              coverUrl: state.book?.coverUrl,
            ),
            const SizedBox(height: DesignTokens.space32),
            AppButton(
              text: '완료',
              onPressed: () => _exitSession(context),
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ReadingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.book != null)
          Text(
            state.book!.title,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize20,
              fontWeight: DesignTokens.fontMedium,
              color: DesignTokens.textPrimary,
            ),
          ),
        const SizedBox(height: DesignTokens.space20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '독서 시간',
                value: state.formattedTime,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                label: '읽은 페이지',
                value: '${state.pagesRead} p',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _StatCard(
                label: '페이스',
                value: state.paceLabel,
                icon: Icons.speed_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _saveSession(
    BuildContext context,
    ReadingSessionState state,
  ) async {
    final endPage = _parsedEndPage;
    if (endPage == null || endPage < 0) {
      setState(() => _pageError = '올바른 페이지 번호를 입력하세요');
      return;
    }
    if (endPage < state.startPage) {
      setState(
        () => _pageError = '종료 페이지는 시작 페이지(${state.startPage})보다 작을 수 없습니다',
      );
      return;
    }
    final totalPage = state.book?.totalPage ?? 0;
    if (totalPage > 0 && endPage > totalPage) {
      setState(() => _pageError = '총 페이지 수($totalPage)를 초과할 수 없습니다');
      return;
    }
    setState(() => _pageError = null);

    final success = await ref
        .read(readingSessionProvider.notifier)
        .finishSession(endPage);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(readingSessionProvider).errorMessage ?? '저장에 실패했습니다',
          ),
        ),
      );
    }
  }

  void _confirmDiscard(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 취소'),
        content: const Text('저장하지 않고 나가시겠어요? 이번 독서 기록이 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('계속'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _exitSession(context);
            },
            child: const Text(
              '나가기',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }

  void _exitSession(BuildContext context) {
    ref.read(sessionJustCompletedProvider.notifier).signal();
    ref.read(readingSessionProvider.notifier).reset();
    ref.read(libraryProvider.notifier).loadAllBooks();
    ref.read(dashboardStatsProvider.notifier).refreshBooks();
    context.pop();
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _PreviewChip extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontMedium,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          label,
          style: const TextStyle(
            fontSize: DesignTokens.fontSize12,
            color: DesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: DesignTokens.textSecondary),
          const SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize16,
              fontWeight: DesignTokens.fontMedium,
              color: DesignTokens.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize10,
              color: DesignTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
