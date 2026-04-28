import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
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
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                  ),
                ),
              ),

            // 콘텐츠 오버레이 (어두운 그라디언트)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(DesignTokens.space28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 우상단 아이콘
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'images/snippetbook-removebg.png',
                        width: 32,
                        height: 32,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 타이머
                  Text(
                    data.formattedTime,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: DesignTokens.fontLight,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),

                  // 통계 뱃지
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.menu_book_rounded,
                        label: '${data.pagesRead} pages',
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      if (data.pagesRead > 0)
                        _StatBadge(
                          icon: Icons.speed_rounded,
                          label: data.paceLabel,
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),

                  // 책 제목 + 저자
                  if (showBookTitle && data.bookTitle.isNotEmpty) ...[
                    Text(
                      data.bookTitle,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSize14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: DesignTokens.fontMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.bookAuthor.isNotEmpty)
                      Text(
                        data.bookAuthor,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSize12,
                          color: Colors.white.withValues(alpha: 0.55),
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
      color: Colors.white,
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

  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space8,
        vertical: DesignTokens.space4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: DesignTokens.fontSize12,
              fontWeight: DesignTokens.fontMedium,
            ),
          ),
        ],
      ),
    );
  }
}
