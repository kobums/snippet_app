import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor:
          Colors.transparent, // Background handled by AnimatedBackground
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7C5CBF), // --lg-accent
        secondary: Color(0xFF34C759), // --lg-like
        error: Color(0xFFFF3B30), // --lg-pass
      ),
    );
  }
}
