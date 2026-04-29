import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/reading_session/presentation/providers/reading_session_provider.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/session_timer_display.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  final UserBookDto book;

  const ActiveSessionScreen({super.key, required this.book});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  int _countdown = 3;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _timers.add(Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _countdown = 2);
    }));
    _timers.add(Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _countdown = 1);
    }));
    _timers.add(Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _countdown = 0);
      ref
          .read(readingSessionProvider.notifier)
          .startSession(widget.book, widget.book.readPage);
    }));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingSessionProvider);
    final notifier = ref.read(readingSessionProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmAbandon(context, notifier);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DesignTokens.primaryMain,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
              children: [
                _buildAppBar(context, state, notifier),
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      child: SessionTimerDisplay(
                        formattedTime: state.formattedTime,
                        isPaused: state.status == SessionStatus.paused,
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space24),
                    child: Text(
                      state.errorMessage!,
                      style: AppTypography.bodySmall.copyWith(
                        color: DesignTokens.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(
                  '${state.startPage}p 에서 시작',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: DesignTokens.space32),
                _buildControls(context, state, notifier),
                const SizedBox(height: DesignTokens.space48),
              ],
            ),
          ),
              if (_countdown > 0) _buildCountdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Positioned.fill(
      child: ColoredBox(
        color: DesignTokens.primaryMain,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              '$_countdown',
              key: ValueKey(_countdown),
              style: AppTypography.displayLarge.copyWith(
                fontSize: 120,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ReadingSessionState state,
    ReadingSessionNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space16,
        DesignTokens.space16,
        DesignTokens.space16,
        DesignTokens.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.book?.title ?? '',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => _confirmAbandon(context, notifier),
            child: Text(
              '포기',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ReadingSessionState state,
    ReadingSessionNotifier notifier,
  ) {
    final isRunning = state.status == SessionStatus.running;
    final isPaused = state.status == SessionStatus.paused;

    return Column(
      children: [
        GestureDetector(
          onTap: isRunning
              ? notifier.pauseSession
              : isPaused
                  ? notifier.resumeSession
                  : null,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        TextButton(
          onPressed: (isRunning || isPaused)
              ? () => _handleFinish(context, notifier)
              : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space32,
              vertical: DesignTokens.space12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Text(
            '독서 완료',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleFinish(
    BuildContext context,
    ReadingSessionNotifier notifier,
  ) async {
    await notifier.prepareFinish();
    if (context.mounted) {
      context.pushReplacement('/sessionComplete');
    }
  }

  void _confirmAbandon(BuildContext context, ReadingSessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('독서 포기'),
        content: const Text('세션을 종료할까요? 기록이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('계속 읽기'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await notifier.abandonSession();
              if (context.mounted) context.pop();
            },
            child: Text(
              '포기',
              style: AppTypography.bodyMedium.copyWith(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}
