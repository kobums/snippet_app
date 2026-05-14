import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class RatingDialog extends StatefulWidget {
  final String bookTitle;
  final int? initialRating;
  final ValueChanged<int?> onRatingSubmit;

  const RatingDialog({
    super.key,
    required this.bookTitle,
    this.initialRating,
    required this.onRatingSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String bookTitle,
    int? initialRating,
    required ValueChanged<int?> onRatingSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RatingDialog(
        bookTitle: bookTitle,
        initialRating: initialRating,
        onRatingSubmit: onRatingSubmit,
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: DesignTokens.space24,
        right: DesignTokens.space24,
        top: DesignTokens.space24,
        bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.space32,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXxs),
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          Text(
            '독서 완료!',
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            widget.bookTitle,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            '이 책은 어떠셨나요?',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled = _selectedRating != null && star <= _selectedRating!;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedRating = _selectedRating == star ? null : star;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: filled ? const Color(0xFFFFB800) : context.colors.border,
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating != null) ...[
            const SizedBox(height: DesignTokens.space8),
            Text(
              _ratingLabel(_selectedRating!),
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.space32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onRatingSubmit(null);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    side: BorderSide(color: context.colors.border),
                  ),
                  child: Text(
                    '건너뛰기',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.space12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedRating != null
                      ? () {
                          Navigator.pop(context);
                          widget.onRatingSubmit(_selectedRating);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: context.colors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                  child: Text(
                    '저장',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    return switch (rating) {
      1 => '별로였어요',
      2 => '조금 아쉬웠어요',
      3 => '괜찮았어요',
      4 => '좋았어요',
      5 => '최고였어요!',
      _ => '',
    };
  }
}
