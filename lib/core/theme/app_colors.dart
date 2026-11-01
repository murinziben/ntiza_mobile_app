import 'package:flutter/material.dart';

/// Exact color tokens from the approved prototype (index.css).
class AppColors {
  AppColors._();

  static const green = Color(0xFF168A45);
  static const greenDark = Color(0xFF0D6532);
  static const mint = Color(0xFFEAF7EF);
  static const ink = Color(0xFF15231B);
  static const muted = Color(0xFF6C7971);
  static const line = Color(0xFFE3E9E5);
  static const canvas = Color(0xFFF5F7F5);
  static const white = Color(0xFFFFFFFF);

  static const amber = Color(0xFFA96500);
  static const amberBg = Color(0xFFFFF8E8);

  static const pendingBg = Color(0xFFFFF2D7);
  static const pendingText = Color(0xFF966000);

  static const inputBorder = Color(0xFFD7DFDA);
  static const inputPrefixBg = Color(0xFFEDF1EE);
  static const navInactive = Color(0xFF849087);
  static const dotInactive = Color(0xFFCFD7D1);

  static const stripDark = Color(0xFF123D28); // home booking strip
  static const roleDark = Color(0xFF113B27); // profile active-role card
  static const heroStart = Color(0xFF0B512B); // auth hero gradient
  static const heroEnd = Color(0xFF17904A);

  static const badge = Color(0xFFE64D3D); // notification dot
  static const danger = Color(0xFFB83B32);
  static const dangerBg = Color(0xFFFCEDEB);
}

class AppRadius {
  AppRadius._();

  static const input = 11.0;
  static const button = 13.0;
  static const card = 14.0;
  static const hero = 16.0;
  static const pill = 999.0;
}
