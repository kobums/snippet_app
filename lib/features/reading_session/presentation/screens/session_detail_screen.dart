import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class SessionDetailScreen extends StatelessWidget {
  final ReadingSessionDto session;

  const SessionDetailScreen({super.key, required this.session});

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
    final minutes = (secondsPerPage / 60).toStringAsFixed(1);
    return '$minutes분/페이지';
  }

  String _formatSpeed(double secondsPerPage) {
    if (secondsPerPage <= 0) return '-';
    final pagesPerHour = (3600 / secondsPerPage).toStringAsFixed(0);
    return '시간당 약 $pagesPerHour페이지';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '독서 세션',
          style: AppTypography.h4,
        ),
        centerTitle: true,
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
        if (session.bookCoverUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: Image.network(
              session.bookCoverUrl,
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
                session.bookTitle,
                style: AppTypography.h4,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
      child: const Icon(Icons.menu_book_outlined, color: DesignTokens.textTertiary, size: 28),
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
          const Icon(Icons.calendar_today_outlined, size: 18, color: DesignTokens.primaryMain),
          const SizedBox(width: DesignTokens.space12),
          Text(
            _formatDate(session.sessionDate),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: DesignTokens.fontMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('세션 요약', style: AppTypography.labelLarge.copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.timer_outlined,
                label: '독서 시간',
                value: _formatDuration(session.durationSeconds),
                color: DesignTokens.primaryMain,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: _statCard(
                icon: Icons.auto_stories_outlined,
                label: '읽은 페이지',
                value: '${session.pagesRead}페이지',
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
          Text(
            value,
            style: AppTypography.h4.copyWith(color: color),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: DesignTokens.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalRange = session.endPage - session.startPage + 1;
    final progress = totalRange > 0 ? session.pagesRead / totalRange : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('페이지 진행', style: AppTypography.labelLarge.copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        GlassContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pageLabel('시작', session.startPage),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: DesignTokens.textTertiary),
                  _pageLabel('종료', session.endPage),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
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
                  '+${session.pagesRead}p 읽음',
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
        Text(label, style: AppTypography.labelSmall.copyWith(color: DesignTokens.textTertiary)),
        const SizedBox(height: DesignTokens.space4),
        Text(
          '$page p',
          style: AppTypography.bodyLarge.copyWith(fontWeight: DesignTokens.fontSemiBold),
        ),
      ],
    );
  }

  Widget _buildPaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('읽기 속도', style: AppTypography.labelLarge.copyWith(color: DesignTokens.textSecondary)),
        const SizedBox(height: DesignTokens.space12),
        GlassContainer(
          child: Row(
            children: [
              const Icon(Icons.speed_outlined, size: 20, color: DesignTokens.textSecondary),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPace(session.secondsPerPage),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: DesignTokens.fontMedium,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space4),
                    Text(
                      _formatSpeed(session.secondsPerPage),
                      style: AppTypography.labelSmall.copyWith(color: DesignTokens.textSecondary),
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
