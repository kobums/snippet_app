import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/shareable_reading_calendar.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/calendar_provider.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';

class ReadingCalendarScreen extends ConsumerStatefulWidget {
  final int? initialYear;
  final int? initialMonth;

  const ReadingCalendarScreen({super.key, this.initialYear, this.initialMonth});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState extends ConsumerState<ReadingCalendarScreen> {
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    // 초기 년월이 전달되면 calendarProvider에 설정하고 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final year = widget.initialYear ?? DateTime.now().year;
      final month = widget.initialMonth ?? DateTime.now().month;
      ref.read(calendarProvider.notifier).setMonth(year, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);

    final completedBooks = calendarState.books
        .where((book) => book.status == BookStatus.completed)
        .toList();

    final now = DateTime.now();
    final isCurrentMonth =
        calendarState.selectedYear == now.year &&
        calendarState.selectedMonth == now.month;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: const AppAppBar(title: '독서 캘린더'),
      body: AppRefreshIndicator(
        onRefresh: () async {
          await ref
              .read(calendarProvider.notifier)
              .setMonth(
                calendarState.selectedYear,
                calendarState.selectedMonth,
              );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyMonthNavigator(
                year: calendarState.selectedYear,
                month: calendarState.selectedMonth,
                isCurrentMonth: isCurrentMonth,
                onMonthChanged: (year, month) {
                  ref.read(calendarProvider.notifier).setMonth(year, month);
                },
                height: 64,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AspectRatio(
                    aspectRatio: 1080 / 1350,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 1080,
                        height: 1350,
                        child: ShareableReadingCalendar(
                          completedBooks: completedBooks,
                          year: calendarState.selectedYear,
                          month: calendarState.selectedMonth,
                          showTitle: false,
                          showStats: _showStats,
                          isDark: context.isDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 통계 표시 스위치
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                      vertical: DesignTokens.space12,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: context.colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '캘린더에 통계 표시',
                            style: AppTypography.labelMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: _showStats,
                          onChanged: (value) {
                            setState(() {
                              _showStats = value;
                            });
                          },
                          activeTrackColor: context.colors.primary,
                          activeThumbColor: context.colors.surface,
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // Container(
                  //   padding: const EdgeInsets.all(DesignTokens.space16),
                  //   decoration: BoxDecoration(
                  //     color: context.colors.primary.withValues(alpha: 0.05),
                  //     borderRadius: BorderRadius.circular(
                  //       DesignTokens.radiusMd,
                  //     ),
                  //     border: Border.all(
                  //       color: context.colors.primary.withValues(alpha: 0.1),
                  //     ),
                  //   ),
                  //   child: const Row(
                  //     children: [
                  //       Icon(
                  //         Icons.info_outline,
                  //         color: context.colors.primary,
                  //         size: 20,
                  //       ),
                  //       SizedBox(width: 12),
                  //       Expanded(
                  //         child: Text(
                  //           '저장 버튼으로 갤러리에 저장하거나, 공유 버튼으로 Instagram 등에 공유할 수 있습니다.',
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             color: DesignTokens.textSecondary,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: '저장',
                          icon: Icons.save_alt,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: calendarState.isSaving,
                          onPressed: calendarState.isSaving
                              ? null
                              : () => ref
                                    .read(calendarProvider.notifier)
                                    .saveToGallery(
                                      context,
                                      completedBooks,
                                      showStats: _showStats,
                                      isDark: context.isDark,
                                    ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: '공유',
                          icon: Icons.share,
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: calendarState.isSharing,
                          onPressed: calendarState.isSharing
                              ? null
                              : () => ref
                                    .read(calendarProvider.notifier)
                                    .shareCalendar(
                                      context,
                                      completedBooks,
                                      showStats: _showStats,
                                      isDark: context.isDark,
                                    ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
