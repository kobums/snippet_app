import 'package:flutter/material.dart';

/// Semantic color extension — 라이트/다크 테마에 따라 자동 전환되는 색상
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.glassLight,
    required this.glassMedium,
    required this.glassDark,
    required this.glassBorder,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.overlay,
    required this.cardBackground,
    required this.inputFill,
    required this.iconSecondary,
  });

  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  /// 테마에 따라 자동 전환되는 primary 색상 (light: 0xFF1A1A1A, dark: 0xFFFFFFFF)
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color border;
  final Color divider;

  /// 글래스모피즘 배경색 — GlassLevel에 따라 선택
  final Color glassLight;   // GlassLevel.strong
  final Color glassMedium;  // GlassLevel.medium
  final Color glassDark;    // GlassLevel.subtle
  final Color glassBorder;

  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color overlay;
  final Color cardBackground;
  final Color inputFill;
  final Color iconSecondary;

  static const light = AppColors(
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF0F0F5),
    surfaceTertiary: Color(0xFFF8F8FA),
    primary: Color(0xFF1A1A1A),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    textTertiary: Color(0xFF999999),
    textDisabled: Color(0xFFCCCCCC),
    border: Color(0xFFE0E0E0),
    divider: Color(0xFFEEEEEE),
    glassLight: Color(0xFAFFFFFF),   // white 0.98
    glassMedium: Color(0xF2FFFFFF),  // white 0.95
    glassDark: Color(0xE6FFFFFF),    // white 0.90
    glassBorder: Color(0xCCFFFFFF),  // white 0.80
    shimmerBase: Color(0xFFEEEEEE),
    shimmerHighlight: Color(0xFFF5F5F5),
    overlay: Color(0x33000000),      // black 0.20
    cardBackground: Color(0xFFFFFFFF),
    inputFill: Color(0xFAFFFFFF),
    iconSecondary: Color(0xFF999999),
  );

  static const dark = AppColors(
    surface: Color(0xFF1C1C1E),
    surfaceSecondary: Color(0xFF2C2C2E),
    surfaceTertiary: Color(0xFF3A3A3C),
    primary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAEAEB2),
    textTertiary: Color(0xFF636366),
    textDisabled: Color(0xFF48484A),
    border: Color(0xFF38383A),
    divider: Color(0xFF38383A),
    glassLight: Color(0xCC2C2C2E),   // surfaceSecondary 0.80
    glassMedium: Color(0xB31C1C1E),  // surface 0.70
    glassDark: Color(0x801C1C1E),    // surface 0.50
    glassBorder: Color(0x29FFFFFF),  // white 0.16
    shimmerBase: Color(0xFF2C2C2E),
    shimmerHighlight: Color(0xFF3A3A3C),
    overlay: Color(0x66000000),      // black 0.40
    cardBackground: Color(0xFF2C2C2E),
    inputFill: Color(0xFF2C2C2E),
    iconSecondary: Color(0xFF636366),
  );

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? primary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? glassLight,
    Color? glassMedium,
    Color? glassDark,
    Color? glassBorder,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? overlay,
    Color? cardBackground,
    Color? inputFill,
    Color? iconSecondary,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      primary: primary ?? this.primary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      glassLight: glassLight ?? this.glassLight,
      glassMedium: glassMedium ?? this.glassMedium,
      glassDark: glassDark ?? this.glassDark,
      glassBorder: glassBorder ?? this.glassBorder,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      overlay: overlay ?? this.overlay,
      cardBackground: cardBackground ?? this.cardBackground,
      inputFill: inputFill ?? this.inputFill,
      iconSecondary: iconSecondary ?? this.iconSecondary,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      glassLight: Color.lerp(glassLight, other.glassLight, t)!,
      glassMedium: Color.lerp(glassMedium, other.glassMedium, t)!,
      glassDark: Color.lerp(glassDark, other.glassDark, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
    );
  }
}

extension ThemeExt on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
