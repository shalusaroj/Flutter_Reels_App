import 'package:flutter/material.dart';

abstract class AppPalette {
  const AppPalette._();

  // Brand
  static const Color primary = Color(0xFF0FA37F);
  static const Color secondary = Color(0xFF17B890);
  static const Color accent = Color(0xFFFF7A1A);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);

  // Neutral
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces
  static const Color transparent = Color(0x00000000);
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111827);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primary,
    onPrimary: white,
    secondary: secondary,
    onSecondary: white,
    tertiary: accent,
    onTertiary: white,
    error: error,
    onError: white,
    surface: surface,
    onSurface: neutral900,
    onSurfaceVariant: neutral500,
    outline: neutral300,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: secondary,
    onPrimary: white,
    secondary: primary,
    onSecondary: white,
    tertiary: accent,
    onTertiary: white,
    error: error,
    onError: white,
    surface: surfaceDark,
    onSurface: neutral100,
    onSurfaceVariant: neutral300,
    outline: neutral700,
  );
}
