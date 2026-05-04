import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Reference UI: orange accent on white — exactly like Mata Kampus screenshots
  static const Color primary = Color(0xFFF5A623); // warm orange
  static const Color primaryDark = Color(0xFFE0921A);
  static const Color primaryLight = Color(0xFFFFC55A);
  static const Color accent = Color(0xFFF5A623);

  // Backgrounds — white/light
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF8F9FA);

  // Status
  static const Color success = Color(0xFF2B9348);
  static const Color error = Color(0xFFD62828);
  static const Color warning = Color(0xFFF5A623);
  static const Color emergency = Color(0xFFD62828);
  static const Color found = Color(0xFF2B9348);
  static const Color lost = Color(0xFFD62828);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E); // very dark navy
  static const Color textSecondary = Color(0xFF4A4A68);
  static const Color textMuted = Color(0xFFAAAAAA);

  // Border
  static const Color border = Color(0xFFEEEEEE);
  static const Color borderLight = Color(0xFFF5F5F5);

  // Legacy aliases
  static const Color teal = Color(0xFF2B9348);
  static const Color blue = Color(0xFF1A1A2E);
  static const Color red = Color(0xFFD62828);
  static const Color green = Color(0xFF2B9348);
  static const Color pink = Color(0xFFD62828);
  static const Color gold = Color(0xFFF5A623);
}

const String kBaseUrl = 'http://10.0.2.2/kayfi2';

TextTheme _buildTextTheme() {
  final base = GoogleFonts.nunitoSansTextTheme();
  return base.copyWith(
    bodyLarge: base.bodyLarge?.copyWith(color: AppColors.textPrimary),
    bodyMedium: base.bodyMedium?.copyWith(color: AppColors.textPrimary),
    titleLarge: base.titleLarge
        ?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: _buildTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      hintStyle:
          GoogleFonts.nunitoSans(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle:
            GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.nunitoSans(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700),
    ),
    dividerColor: AppColors.border,
  );
}
