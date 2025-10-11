import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtlyTheme {
  // Brand Colors
  static const Color vitalityGreen = Color(0xFF4ADE80);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF3A3A3A);
  static const Color darkText = Color(0xFF1E1E1E);
  static const Color mediumGray = Color(0xFF7C7C7C);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color lightGreenTint = Color(0xFFE6F9ED);
  static const Color black = Color(0xFF000000);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pureWhite,
      colorScheme: ColorScheme.light(
        primary: vitalityGreen,
        secondary: vitalityGreen,
        surface: pureWhite,
        error: Colors.red.shade400,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: pureWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vitalityGreen,
          foregroundColor: pureWhite,
          elevation: 2,
          shadowColor: vitalityGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGray,
          side: const BorderSide(color: lightGray, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: vitalityGreen, width: 2),
        ),
      ),
    );
  }

  // Common animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Common animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceIn = Curves.elasticOut;
}
