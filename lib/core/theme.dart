import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
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

      // Theme Extensions
      extensions: const [AppColors.light],
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        primaryContainer: DesignTokens.darkBgSecondary,
        secondary: DesignTokens.secondaryMain,
        secondaryContainer: Color(0xFF1A3A26),
        tertiary: DesignTokens.darkTextSecondary,
        surface: DesignTokens.darkBgPrimary,
        surfaceContainerHighest: DesignTokens.darkBgTertiary,
        error: DesignTokens.error,
        onPrimary: DesignTokens.darkBgPrimary,
        onSecondary: Colors.white,
        onSurface: DesignTokens.darkTextPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DesignTokens.darkBgPrimary,
        foregroundColor: DesignTokens.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.h2.copyWith(
          color: DesignTokens.darkTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: DesignTokens.darkTextPrimary,
          size: DesignTokens.iconMd,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: DesignTokens.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: DesignTokens.darkBgSecondary,
        shadowColor: Colors.black.withValues(alpha: 0.20),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space8,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: DesignTokens.darkBgPrimary,
          disabledBackgroundColor: DesignTokens.darkNeutral300,
          disabledForegroundColor: DesignTokens.darkTextDisabled,
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
          textStyle: AppTypography.button.copyWith(
            color: DesignTokens.darkBgPrimary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
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

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: Colors.white,
        foregroundColor: DesignTokens.darkBgPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.darkBgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.darkNeutral300,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: DesignTokens.darkNeutral300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: Colors.white,
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
          color: DesignTokens.darkTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: DesignTokens.darkTextTertiary,
        ),
        errorStyle: AppTypography.caption.copyWith(color: DesignTokens.error),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: DesignTokens.darkTextSecondary,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: DesignTokens.fontRegular,
        ),
        overlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: DesignTokens.darkNeutral200,
        thickness: 1,
        space: DesignTokens.space16,
      ),

      iconTheme: const IconThemeData(
        color: DesignTokens.darkTextPrimary,
        size: DesignTokens.iconMd,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.displayLarge.copyWith(color: DesignTokens.darkTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: DesignTokens.darkTextPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: DesignTokens.darkTextPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: DesignTokens.darkTextPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: DesignTokens.darkTextPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: DesignTokens.darkTextPrimary),
        titleLarge: AppTypography.h4.copyWith(color: DesignTokens.darkTextPrimary),
        titleMedium: AppTypography.labelLarge.copyWith(color: DesignTokens.darkTextPrimary),
        titleSmall: AppTypography.labelMedium.copyWith(color: DesignTokens.darkTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: DesignTokens.darkTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: DesignTokens.darkTextPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: DesignTokens.darkTextSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: DesignTokens.darkTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: DesignTokens.darkTextPrimary),
        labelSmall: AppTypography.labelSmall.copyWith(color: DesignTokens.darkTextSecondary),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
        circularTrackColor: DesignTokens.darkNeutral300,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.darkBgTertiary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: DesignTokens.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2xl),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.darkBgSecondary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: DesignTokens.darkTextPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: DesignTokens.darkTextPrimary),
      ),

      extensions: const [AppColors.dark],
    );
  }
}
