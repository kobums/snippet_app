import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Typography System - Fintech Style
/// 일관된 타이포그래피 스타일을 제공하는 헬퍼 클래스
class AppTypography {
  AppTypography._();

  // ========== Display ==========

  /// Display Large - 매우 큰 제목 (예: 숫자 통계)
  static const TextStyle displayLarge = TextStyle(
    fontSize: DesignTokens.fontSize48,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightTight,
    letterSpacing: DesignTokens.letterSpacingTight,
    color: DesignTokens.textPrimary,
  );

  /// Display Medium
  static const TextStyle displayMedium = TextStyle(
    fontSize: DesignTokens.fontSize40,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightTight,
    letterSpacing: DesignTokens.letterSpacingTight,
    color: DesignTokens.textPrimary,
  );

  /// Display Small
  static const TextStyle displaySmall = TextStyle(
    fontSize: DesignTokens.fontSize32,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.textPrimary,
  );

  // ========== Heading ==========

  /// Heading 1 - 페이지 제목
  static const TextStyle h1 = TextStyle(
    fontSize: DesignTokens.fontSize28,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWidest,
    color: DesignTokens.textPrimary,
  );

  /// Heading 2 - 섹션 제목
  static const TextStyle h2 = TextStyle(
    fontSize: DesignTokens.fontSize24,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWider,
    color: DesignTokens.textPrimary,
  );

  /// Heading 3 - 서브 섹션 제목
  static const TextStyle h3 = TextStyle(
    fontSize: DesignTokens.fontSize20,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textPrimary,
  );

  /// Heading 4 - 카드 제목
  static const TextStyle h4 = TextStyle(
    fontSize: DesignTokens.fontSize18,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textPrimary,
  );

  // ========== Body ==========

  /// Body Large - 큰 본문
  static const TextStyle bodyLarge = TextStyle(
    fontSize: DesignTokens.fontSize16,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightRelaxed,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.textPrimary,
  );

  /// Body Medium - 기본 본문
  static const TextStyle bodyMedium = TextStyle(
    fontSize: DesignTokens.fontSize14,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightRelaxed,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.textPrimary,
  );

  /// Body Small - 작은 본문
  static const TextStyle bodySmall = TextStyle(
    fontSize: DesignTokens.fontSize12,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.textSecondary,
  );

  // ========== Label ==========

  /// Label Large - 큰 라벨
  static const TextStyle labelLarge = TextStyle(
    fontSize: DesignTokens.fontSize16,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textPrimary,
  );

  /// Label Medium - 기본 라벨
  static const TextStyle labelMedium = TextStyle(
    fontSize: DesignTokens.fontSize14,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textPrimary,
  );

  /// Label Small - 작은 라벨 (버튼, 태그 등)
  static const TextStyle labelSmall = TextStyle(
    fontSize: DesignTokens.fontSize12,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textSecondary,
  );

  // ========== Caption ==========

  /// Caption - 작은 설명 텍스트
  static const TextStyle caption = TextStyle(
    fontSize: DesignTokens.fontSize12,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textTertiary,
  );

  /// Caption Small - 매우 작은 설명
  static const TextStyle captionSmall = TextStyle(
    fontSize: DesignTokens.fontSize10,
    fontWeight: DesignTokens.fontRegular,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: DesignTokens.textTertiary,
  );

  // ========== Special ==========

  /// Quote - 인용문 스타일 (스와이프 카드용)
  static const TextStyle quote = TextStyle(
    fontSize: DesignTokens.fontSize20,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightRelaxed,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.textPrimary,
  );

  /// Brand - 브랜드 로고 타이포
  static const TextStyle brand = TextStyle(
    fontSize: DesignTokens.fontSize28,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingExtraWide,
    color: DesignTokens.primaryMain,
  );

  /// Number Large - 큰 숫자 (통계)
  static const TextStyle numberLarge = TextStyle(
    fontSize: DesignTokens.fontSize40,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightTight,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.primaryMain,
  );

  /// Number Medium - 중간 숫자
  static const TextStyle numberMedium = TextStyle(
    fontSize: DesignTokens.fontSize24,
    fontWeight: DesignTokens.fontLight,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingNormal,
    color: DesignTokens.primaryMain,
  );

  /// Button Text - 버튼 텍스트
  static const TextStyle button = TextStyle(
    fontSize: DesignTokens.fontSize16,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWider,
    color: Colors.white,
  );

  /// Button Text Small
  static const TextStyle buttonSmall = TextStyle(
    fontSize: DesignTokens.fontSize14,
    fontWeight: DesignTokens.fontMedium,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: DesignTokens.letterSpacingWide,
    color: Colors.white,
  );

  // ========== Utility Methods ==========

  /// 색상 변경 헬퍼
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 굵기 변경 헬퍼
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// 투명도 적용 헬퍼
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withValues(alpha: opacity),
    );
  }
}
