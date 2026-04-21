import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';

class SessionStatsRow extends StatelessWidget {
  final int pagesRead;
  final String paceLabel;
  final int currentPage;
  final int totalPage;
  final VoidCallback onPagesTap;

  const SessionStatsRow({
    super.key,
    required this.pagesRead,
    required this.paceLabel,
    required this.currentPage,
    required this.totalPage,
    required this.onPagesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
          label: '읽은 페이지',
          value: '$pagesRead p',
          onTap: onPagesTap,
          tappable: true,
        ),
        _Divider(),
        _StatChip(
          label: '현재 페이지',
          value: '$currentPage / $totalPage',
          onTap: onPagesTap,
          tappable: true,
        ),
        _Divider(),
        _StatChip(
          label: '페이스',
          value: paceLabel,
          tappable: false,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool tappable;

  const _StatChip({
    required this.label,
    required this.value,
    this.onTap,
    required this.tappable,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tappable ? onTap : null,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: DesignTokens.fontSize20,
              fontWeight: DesignTokens.fontMedium,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: DesignTokens.fontSize12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              if (tappable) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.edit,
                  size: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
