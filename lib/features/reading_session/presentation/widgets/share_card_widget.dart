import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/features/reading_session/presentation/providers/reading_session_provider.dart';

// ─── 공유 카드 데이터 모델 ─────────────────────────────────────────────────────

class ShareCardData {
  final String formattedTime;
  final int pagesRead;
  final String paceLabel;
  final String bookTitle;
  final String bookAuthor;
  final String? localPhotoPath;
  final String? networkCoverUrl;

  const ShareCardData({
    required this.formattedTime,
    required this.pagesRead,
    required this.paceLabel,
    required this.bookTitle,
    required this.bookAuthor,
    this.localPhotoPath,
    this.networkCoverUrl,
  });

  factory ShareCardData.fromSessionState(ReadingSessionState state) {
    return ShareCardData(
      formattedTime: state.formattedTime,
      pagesRead: state.pagesRead,
      paceLabel: state.paceLabel,
      bookTitle: state.book?.title ?? '',
      bookAuthor: state.book?.author ?? '',
      localPhotoPath: state.photoPath,
      networkCoverUrl: state.book?.coverUrl,
    );
  }

  factory ShareCardData.fromDto(ReadingSessionDto dto) {
    final h = dto.durationSeconds ~/ 3600;
    final m = (dto.durationSeconds % 3600) ~/ 60;
    final s = dto.durationSeconds % 60;
    final formatted =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final paceLabel = dto.pagesRead == 0
        ? '--'
        : '${(dto.secondsPerPage / 60).toStringAsFixed(1)} min/p';
    return ShareCardData(
      formattedTime: formatted,
      pagesRead: dto.pagesRead,
      paceLabel: paceLabel,
      bookTitle: dto.bookTitle,
      bookAuthor: dto.bookAuthor,
      networkCoverUrl: dto.bookCoverUrl.isNotEmpty ? dto.bookCoverUrl : null,
    );
  }

  ShareCardData copyWith({
    String? localPhotoPath,
    String? networkCoverUrl,
    bool clearLocalPhoto = false,
    bool clearNetworkCover = false,
  }) {
    return ShareCardData(
      formattedTime: formattedTime,
      pagesRead: pagesRead,
      paceLabel: paceLabel,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      localPhotoPath: clearLocalPhoto
          ? null
          : (localPhotoPath ?? this.localPhotoPath),
      networkCoverUrl: clearNetworkCover
          ? null
          : (networkCoverUrl ?? this.networkCoverUrl),
    );
  }
}

// ─── 공유 카드 위젯 ───────────────────────────────────────────────────────────

class ShareCardWidget extends StatelessWidget {
  final ShareCardData data;
  final bool showBookTitle;

  const ShareCardWidget({
    super.key,
    required this.data,
    this.showBookTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    // 로컬 사진 배경은 내용물을 알 수 없으므로 항상 흰색 텍스트 유지
    // 책 표지(surface 배경) / 그라디언트는 테마에 맞춰 반전
    final bool hasPhotoBackground = data.localPhotoPath != null;
    final Color contentColor =
        hasPhotoBackground ? Colors.white : context.colors.textPrimary;
    final Color contentColorSubtle = hasPhotoBackground
        ? Colors.white.withValues(alpha: 0.55)
        : context.colors.textSecondary;
    final Color badgeBackground = hasPhotoBackground
        ? Colors.white.withValues(alpha: 0.15)
        : context.colors.textPrimary.withValues(alpha: 0.08);

    return AspectRatio(
      aspectRatio: 1080 / 1350,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 배경: 로컬 사진 > 책 표지(네트워크) > 단색 그라디언트
            if (data.localPhotoPath != null)
              _LocalPhoto(path: data.localPhotoPath!)
            else if (data.networkCoverUrl != null)
              _NetworkPhoto(url: data.networkCoverUrl!)
            else
              _GradientBackground(isDark: context.isDark),

            Padding(
              padding: const EdgeInsets.all(DesignTokens.space28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 우상단 아이콘 — 배경색과 반대 색으로 틴트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(contentColor, BlendMode.srcIn),
                        child: Image.asset(
                          'images/snippetbook-removebg.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 타이머
                  Text(
                    data.formattedTime,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 52,
                      fontWeight: DesignTokens.fontLight,
                      color: contentColor,
                      letterSpacing: 2,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),

                  // 통계 뱃지
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.menu_book_rounded,
                        label: '${data.pagesRead} pages',
                        contentColor: contentColor,
                        backgroundColor: badgeBackground,
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      if (data.pagesRead > 0)
                        _StatBadge(
                          icon: Icons.speed_rounded,
                          label: data.paceLabel,
                          contentColor: contentColor,
                          backgroundColor: badgeBackground,
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),

                  // 책 제목 + 저자
                  if (showBookTitle && data.bookTitle.isNotEmpty) ...[
                    Text(
                      data.bookTitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: contentColor.withValues(alpha: 0.9),
                        fontWeight: DesignTokens.fontMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.bookAuthor.isNotEmpty)
                      Text(
                        data.bookAuthor,
                        style: AppTypography.bodySmall.copyWith(
                          color: contentColorSubtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 배경 이미지 위젯 ─────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  final bool isDark;
  const _GradientBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
              : [const Color(0xFFE8E8E8), const Color(0xFFF5F5F5)],
        ),
      ),
    );
  }
}

class _LocalPhoto extends StatelessWidget {
  final String path;
  const _LocalPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: DesignTokens.primaryMain),
    );
  }
}

class _NetworkPhoto extends StatelessWidget {
  final String url;
  const _NetworkPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
        ),
      ),
    );
  }
}

// ─── 통계 뱃지 ───────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color contentColor;
  final Color backgroundColor;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.contentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: contentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: contentColor,
              fontWeight: DesignTokens.fontMedium,
            ),
          ),
        ],
      ),
    );
  }
}
