import 'package:flutter/material.dart';

/// Colour tokens sampled from the NTIZA mobile design.
class AppColors {
  AppColors._();

  /// Slightly darker than the Figma green (#16A34A) so white text on it meets
  /// the 4.5:1 WCAG AA contrast ratio (5.0:1).
  static const primary = Color(0xFF15803D);
  static const primaryDark = Color(0xFF166534);
  static const green100 = Color(0xFFDCFCE7);
  static const green50 = Color(0xFFF0FDF4);

  static const page = Color(0xFFF9FAFB);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const ink = Color(0xFF111827);
  static const body = Color(0xFF374151);
  static const muted = Color(0xFF5B6270);
  static const faint = Color(0xFF6F7684);
  static const neutral = Color(0xFFF3F4F6);

  static const blue = Color(0xFF1D4ED8);
  static const blueBg = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberText = Color(0xFF92400E);
  static const amberBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFB91C1C);
  static const dangerBg = Color(0xFFFEE2E2);
  static const purple = Color(0xFF6D28D9);
  static const purpleBg = Color(0xFFEDE9FE);
}

class AppRadius {
  AppRadius._();
  static const card = 18.0;
  static const input = 14.0;
  static const button = 14.0;
  static const pill = 999.0;
}
