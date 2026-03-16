import 'package:flutter/material.dart';

/// Design Tokens - Fintech Style Design System
/// 핀테크 앱을 위한 세련되고 일관된 디자인 토큰 시스템
class DesignTokens {
  DesignTokens._();

  // ========== Colors ==========

  /// Primary Colors - 브랜드 메인 컬러 (보라 계열)
  static const Color primaryMain = Color(0xFF7C5CBF);
  static const Color primaryLight = Color(0xFF9B7FD9);
  static const Color primaryDark = Color(0xFF5D3EA6);
  static const Color primarySubtle = Color(0xFFE8E0F5);

  /// Secondary Colors - 보조 컬러 (그린 계열)
  static const Color secondaryMain = Color(0xFF34C759);
  static const Color secondaryLight = Color(0xFF5DD97C);
  static const Color secondaryDark = Color(0xFF28A745);
  static const Color secondarySubtle = Color(0xFFE5F7EC);

  /// Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  /// Neutral Colors - 회색 팔레트
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  /// Background Colors
  static const Color bgPrimary = Color(0xFFF0F0F5);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFF8F8FA);

  /// Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  /// Glass Colors (for Glassmorphism)
  static final Color glassLight = Colors.white.withValues(alpha: 0.98);
  static final Color glassMedium = Colors.white.withValues(alpha: 0.95);
  static final Color glassDark = Colors.white.withValues(alpha: 0.90);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.8);

  // ========== Typography ==========

  /// Font Sizes
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize40 = 40.0;
  static const double fontSize48 = 48.0;

  /// Font Weights
  static const FontWeight fontLight = FontWeight.w300;
  static const FontWeight fontRegular = FontWeight.w400;
  static const FontWeight fontMedium = FontWeight.w500;
  static const FontWeight fontSemiBold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;

  /// Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  /// Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;
  static const double letterSpacingWidest = 2.0;
  static const double letterSpacingExtraWide = 5.0;

  // ========== Spacing ==========

  /// 4px 기반 스케일
  static const double space0 = 0.0;
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;

  // ========== Border Radius ==========

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 28.0;
  static const double radiusFull = 9999.0;

  // ========== Shadows ==========

  /// Elevation 1 - 미묘한 그림자
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Elevation 2 - 카드
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Elevation 3 - 떠있는 요소
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Elevation 4 - 모달, 드로어
  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Glass Shadow - 글래스모피즘용 그림자
  static List<BoxShadow> get shadowGlass => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ];

  // ========== Blur ==========

  static const double blurSm = 8.0;
  static const double blurMd = 16.0;
  static const double blurLg = 24.0;
  static const double blurXl = 40.0;

  // ========== Sizes ==========

  /// Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double icon2xl = 48.0;

  /// Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  /// Input Heights
  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;

  /// Bottom Navigation Height (base height without safe area)
  static const double bottomNavHeight = 72.0;

  /// Bottom Navigation Total Height with typical safe area
  static const double bottomNavTotalHeight = 96.0; // 72 + ~24 safe area

  // ========== Animations ==========

  /// Duration
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationVerySlow = Duration(milliseconds: 600);

  /// Curves
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveSpring = Curves.easeOutBack;

  // ========== Gradients ==========

  /// Primary Gradient
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryMain],
  );

  /// Success Gradient
  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryMain],
  );

  /// Shimmer Gradient (로딩 효과)
  static const LinearGradient gradientShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neutral200,
      neutral100,
      neutral200,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Glass Gradient (글래스모피즘 배경)
  static LinearGradient get gradientGlass => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.85),
        ],
      );
}
