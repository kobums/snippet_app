import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_section.dart';
import 'package:snippet_app/features/reading_session/presentation/widgets/share_card_widget.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class SessionDetailScreen extends StatefulWidget {
  final ReadingSessionDto session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final weekday = weekdays[date.weekday - 1];
      return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '$h시간 $m분';
    if (m > 0) return '$m분 $s초';
    return '$s초';
  }

  String _formatPace(double secondsPerPage) {
    if (secondsPerPage <= 0) return '-';
    return '${(secondsPerPage / 60).toStringAsFixed(1)}분/페이지';
  }

  String _formatSpeed(double secondsPerPage) {
    if (secondsPerPage <= 0) return '-';
    final pagesPerHour = (3600 / secondsPerPage).toStringAsFixed(0);
    return '시간당 약 $pagesPerHour페이지';
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareBottomSheet(session: widget.session),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('독서 세션', style: AppTypography.h4),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded,
                color: DesignTokens.textPrimary),
            onPressed: _openShareSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(),
            const SizedBox(height: DesignTokens.space24),
            _buildDateBadge(),
            const SizedBox(height: DesignTokens.space24),
            _buildStatsGrid(),
            const SizedBox(height: DesignTokens.space24),
            _buildProgressSection(),
            const SizedBox(height: DesignTokens.space24),
            _buildPaceSection(),
            const SizedBox(height: DesignTokens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildBookHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.session.bookCoverUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: Image.network(
              widget.session.bookCoverUrl,
              width: 72,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _bookCoverPlaceholder(),
            ),
          )
        else
          _bookCoverPlaceholder(),
        const SizedBox(width: DesignTokens.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.session.bookTitle,
                style: AppTypography.h4,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.session.bookAuthor.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.space4),
                Text(
                  widget.session.bookAuthor,
                  style: AppTypography.labelSmall
                      .copyWith(color: DesignTokens.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: DesignTokens.space8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space8,
                  vertical: DesignTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryMain.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                ),
                child: Text(
                  '독서 완료',
                  style: AppTypography.labelSmall.copyWith(
                    color: DesignTokens.primaryMain,
                    fontWeight: DesignTokens.fontMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookCoverPlaceholder() {
    return Container(
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        color: DesignTokens.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: const Icon(Icons.menu_book_outlined,
          color: DesignTokens.textTertiary, size: 28),
    );
  }

  Widget _buildDateBadge() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space12,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: DesignTokens.primaryMain),
          const SizedBox(width: DesignTokens.space12),
          Text(
            _formatDate(widget.session.sessionDate),
            style: AppTypography.bodyMedium
                .copyWith(fontWeight: DesignTokens.fontMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('세션 요약',
            style: AppTypography.labelLarge
                .copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.timer_outlined,
                label: '독서 시간',
                value: _formatDuration(widget.session.durationSeconds),
                color: DesignTokens.primaryMain,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _statCard(
                icon: Icons.auto_stories_outlined,
                label: '읽은 페이지',
                value: '${widget.session.pagesRead}페이지',
                color: DesignTokens.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: DesignTokens.space8),
          Text(value, style: AppTypography.h4.copyWith(color: color)),
          const SizedBox(height: DesignTokens.space4),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: DesignTokens.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalRange =
        widget.session.endPage - widget.session.startPage + 1;
    final progress =
        totalRange > 0 ? widget.session.pagesRead / totalRange : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('페이지 진행',
            style: AppTypography.labelLarge
                .copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        GlassContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pageLabel('시작', widget.session.startPage),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: DesignTokens.textTertiary),
                  _pageLabel('종료', widget.session.endPage),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusXs),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: DesignTokens.neutral100,
                  color: DesignTokens.primaryMain,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '+${widget.session.pagesRead}p 읽음',
                  style: AppTypography.labelSmall.copyWith(
                    color: DesignTokens.success,
                    fontWeight: DesignTokens.fontMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageLabel(String label, int page) {
    return Column(
      children: [
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: DesignTokens.textTertiary)),
        const SizedBox(height: DesignTokens.space4),
        Text('$page p',
            style: AppTypography.bodyLarge
                .copyWith(fontWeight: DesignTokens.fontSemiBold)),
      ],
    );
  }

  Widget _buildPaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('읽기 속도',
            style: AppTypography.labelLarge
                .copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        GlassContainer(
          child: Row(
            children: [
              const Icon(Icons.speed_outlined,
                  size: 20, color: DesignTokens.textSecondary),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPace(widget.session.secondsPerPage),
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: DesignTokens.fontMedium),
                    ),
                    const SizedBox(height: DesignTokens.space4),
                    Text(
                      _formatSpeed(widget.session.secondsPerPage),
                      style: AppTypography.labelSmall
                          .copyWith(color: DesignTokens.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 공유 바텀시트 ─────────────────────────────────────────────────────────────

class _ShareBottomSheet extends StatelessWidget {
  final ReadingSessionDto session;

  const _ShareBottomSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        DesignTokens.space24,
        DesignTokens.space16,
        DesignTokens.space24,
        DesignTokens.space24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignTokens.neutral300,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
          ),
          const SizedBox(height: DesignTokens.space20),
          ShareCardSection(
            initialData: ShareCardData.fromDto(session),
            coverUrl: session.bookCoverUrl,
          ),
        ],
      ),
    );
  }
}
