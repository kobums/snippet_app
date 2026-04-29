import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/features/library/presentation/providers/popular_book_provider.dart';

class PopularBookFilterBar extends ConsumerWidget {
  const PopularBookFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popularBooksProvider);
    final notifier = ref.read(popularBooksProvider.notifier);

    return Container(
      color: context.colors.surface,
      child: Column(
        children: [
          // 기간 필터
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: 6,
              ),
              children: PopularBooksPeriod.values.map((period) {
                final selected = state.selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: period.label,
                    selected: selected,
                    onTap: () => notifier.setPeriod(period),
                  ),
                );
              }).toList(),
            ),
          ),
          // KDC 장르 필터
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: 6,
              ),
              children: kdcCategories.map((kdc) {
                final selected = state.selectedKdc == kdc;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: kdc.label,
                    selected: selected,
                    onTap: () => notifier.setKdc(kdc),
                    accent: true,
                  ),
                );
              }).toList(),
            ),
          ),
          // 연령 필터
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: 6,
              ),
              children: ageFilters.map((age) {
                final selected = state.selectedAge == age;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: age.label,
                    selected: selected,
                    onTap: () => notifier.setAge(age),
                  ),
                );
              }).toList(),
            ),
          ),
          // 성별 필터
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space16,
                vertical: 6,
              ),
              children: genderFilters.map((gender) {
                final selected = state.selectedGender == gender;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: gender.label,
                    selected: selected,
                    onTap: () => notifier.setGender(gender),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, thickness: 1, color: context.colors.border),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool accent;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? context.colors.primary
        : context.colors.surfaceSecondary;
    final fg = selected ? context.colors.surface : context.colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(
            color: selected ? context.colors.primary : context.colors.border,
            width: 1,
          ),
        ),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: fg)),
      ),
    );
  }
}
