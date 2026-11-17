import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.primaryDark,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    outline: AppColors.border,
    error: AppColors.danger,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.page,
    textTheme: _interTextTheme(base.textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
  );
}

/// Applies Inter to every text style using only TextStyle APIs, so it works
/// regardless of which google_fonts / Flutter SDK versions are installed.
TextTheme _interTextTheme(TextTheme t) {
  TextStyle? inter(TextStyle? s) => s == null
      ? null
      : GoogleFonts.inter(textStyle: s.copyWith(color: AppColors.ink));

  return t.copyWith(
    displayLarge: inter(t.displayLarge),
    displayMedium: inter(t.displayMedium),
    displaySmall: inter(t.displaySmall),
    headlineLarge: inter(t.headlineLarge),
    headlineMedium: inter(t.headlineMedium),
    headlineSmall: inter(t.headlineSmall),
    titleLarge: inter(t.titleLarge),
    titleMedium: inter(t.titleMedium),
    titleSmall: inter(t.titleSmall),
    bodyLarge: inter(t.bodyLarge),
    bodyMedium: inter(t.bodyMedium),
    bodySmall: inter(t.bodySmall),
    labelLarge: inter(t.labelLarge),
    labelMedium: inter(t.labelMedium),
    labelSmall: inter(t.labelSmall),
  );
}
