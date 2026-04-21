import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/features/reading_session/presentation/providers/reading_session_provider.dart';

class ShareCardWidget extends StatelessWidget {
  final ReadingSessionState session;
  final bool showBookTitle;

  const ShareCardWidget({
    super.key,
    required this.session,
    this.showBookTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 배경: 사진 or 단색
            if (session.photoPath != null)
              _BlurredPhoto(path: session.photoPath!)
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2D2D2D),
                    ],
                  ),
                ),
              ),

            // 콘텐츠 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(DesignTokens.space28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: Snippet 로고
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space12,
                          vertical: DesignTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusFull),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'snippet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: DesignTokens.fontSize12,
                            fontWeight: DesignTokens.fontMedium,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 큰 타이머
                  Text(
                    session.formattedTime,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: DesignTokens.fontLight,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),

                  // 통계 행
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.menu_book_rounded,
                        label: '${session.pagesRead} pages',
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      if (session.pagesRead > 0)
                        _StatBadge(
                          icon: Icons.speed_rounded,
                          label: session.paceLabel,
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space16),

                  // 책 제목 (숨김/공개 토글)
                  if (showBookTitle && session.book != null)
                    Text(
                      session.book!.title,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSize14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: DesignTokens.fontMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurredPhoto extends StatelessWidget {
  final String path;

  const _BlurredPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: DesignTokens.primaryMain),
    );
  }
}

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
