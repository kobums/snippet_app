import 'package:flutter/material.dart';
import '../../models/stats.dart';
import '../glass_container.dart';

class InsightsCard extends StatelessWidget {
  final ReadingInsightsDto? insights;

  const InsightsCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights == null) {
      return GlassContainer(
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildInsightItem(
          icon: Icons.timelapse,
          title: '평균 독서 기간',
          value: '${insights!.averageReadingDays.toStringAsFixed(1)}일',
          description: '한 권을 읽는데 걸리는 평균 시간',
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          icon: Icons.category,
          title: '선호 카테고리',
          value: insights!.topCategory,
          description: '가장 많이 읽은 카테고리',
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          icon: Icons.emoji_events,
          title: '최장 독서 기록',
          value: '${insights!.longestReadingDays}일',
          description: '가장 오래 읽은 책의 독서 기간',
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          icon: Icons.menu_book,
          title: '가장 오래 읽은 책',
          value: insights!.longestBook,
          description: '가장 오래 걸린 책',
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return GlassContainer(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CBF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7C5CBF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7C5CBF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
