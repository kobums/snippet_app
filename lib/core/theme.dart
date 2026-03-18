import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';
import 'typography.dart';

/// App Theme - Fintech Style
/// 디자인 토큰 기반의 일관된 테마 시스템
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      // Brightness
      brightness: Brightness.light,
      useMaterial3: true,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.primaryMain,
        primaryContainer: DesignTokens.primarySubtle,
        secondary: DesignTokens.secondaryMain,
        secondaryContainer: DesignTokens.secondarySubtle,
        tertiary: DesignTokens.primaryLight,
        surface: DesignTokens.bgPrimary,
        surfaceContainerHighest: DesignTokens.bgTertiary,
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DesignTokens.bgPrimary,
        foregroundColor: DesignTokens.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.h2.copyWith(
          color: DesignTokens.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: DesignTokens.textPrimary,
          size: DesignTokens.iconMd,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: DesignTokens.primaryMain,
        unselectedItemColor: DesignTokens.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: DesignTokens.bgPrimary,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space8,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: DesignTokens.primaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignTokens.neutral300,
          disabledForegroundColor: DesignTokens.textDisabled,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMd),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusMd),
            ),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusMd),
            ),
          ),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryMain,
          side: const BorderSide(color: DesignTokens.primaryMain, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeightMd),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DesignTokens.radiusMd),
            ),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: DesignTokens.primaryMain,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.glassLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.neutral300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.neutral300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.primaryMain,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: DesignTokens.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: DesignTokens.error, width: 2.0),
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: DesignTokens.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: DesignTokens.textTertiary,
        ),
        errorStyle: AppTypography.caption.copyWith(color: DesignTokens.error),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: DesignTokens.primaryMain,
        unselectedLabelColor: DesignTokens.textSecondary,
        indicatorColor: DesignTokens.primaryMain,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: DesignTokens.fontRegular,
        ),
        overlayColor: WidgetStateProperty.all(
          DesignTokens.primaryMain.withValues(alpha: 0.1),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: DesignTokens.neutral200,
        thickness: 1,
        space: DesignTokens.space16,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: DesignTokens.textPrimary,
        size: DesignTokens.iconMd,
      ),

      // Text Theme
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.labelLarge,
        titleSmall: AppTypography.labelMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignTokens.primaryMain,
        circularTrackColor: DesignTokens.neutral200,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.neutral800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2xl),
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.bgPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
        ),
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.bodyMedium,
      ),
    );
  }
}
