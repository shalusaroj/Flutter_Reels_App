import 'package:flutter/material.dart';

import 'app_custom_colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static final appStyles = AppTextStyles.fromTokens();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppPalette.lightColorScheme,
      brightness: Brightness.light,
      fontFamily: 'OpenSans',
      textTheme: TextTheme(
        labelSmall: appStyles.labelSmall,
        bodySmall: appStyles.bodySmall,
        bodyMedium: appStyles.bodyMedium,
        titleMedium: appStyles.titleMedium,
        titleLarge: appStyles.titleLarge,
        headlineSmall: appStyles.headlineSmall,
        displaySmall: appStyles.displaySmall,
      ),
      extensions: [_lightCustomColors, AppTextStyles.fromTokens()],
      scaffoldBackgroundColor: AppPalette.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.neutral900,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.white,
          textStyle: appStyles.bodyMedium.semiBold,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 4,
        shadowColor: const Color(0x80000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppPalette.darkColorScheme,
      brightness: Brightness.dark,
      fontFamily: 'OpenSans',
      textTheme: TextTheme(
        labelSmall: appStyles.labelSmall.copyWith(color: AppPalette.neutral300),
        bodySmall: appStyles.bodySmall.copyWith(color: AppPalette.neutral300),
        bodyMedium: appStyles.bodyMedium.copyWith(color: AppPalette.neutral100),
        titleMedium: appStyles.titleMedium.copyWith(
          color: AppPalette.neutral100,
        ),
        titleLarge: appStyles.titleLarge.copyWith(color: AppPalette.neutral100),
        headlineSmall: appStyles.headlineSmall.copyWith(
          color: AppPalette.neutral100,
        ),
        displaySmall: appStyles.displaySmall.copyWith(
          color: AppPalette.neutral100,
        ),
      ),
      extensions: [_darkCustomColors, AppTextStyles.fromTokens()],
      scaffoldBackgroundColor: AppPalette.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppPalette.backgroundDark,
        foregroundColor: AppPalette.neutral100,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.neutral700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.neutral700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 4,
        shadowColor: const Color(0xE6000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static const AppCustomColors _lightCustomColors = AppCustomColors(
    brand: AppColorFamily(
      base: AppPalette.primary,
      soft: Color(0xFF6CD8BE),
      subtle: Color(0xFFE8F9F4),
    ),
    accent: AppColorFamily(
      base: AppPalette.accent,
      soft: Color(0xFFFFB680),
      subtle: Color(0xFFFFF1E7),
    ),
    success: AppColorFamily(
      base: AppPalette.success,
      soft: Color(0xFF86EFAC),
      subtle: Color(0xFFF0FDF4),
    ),
    warning: AppColorFamily(
      base: AppPalette.warning,
      soft: Color(0xFFFDE68A),
      subtle: Color(0xFFFEFCE8),
    ),
    error: AppColorFamily(
      base: AppPalette.error,
      soft: Color(0xFFFCA5A5),
      subtle: Color(0xFFFEF2F2),
    ),
    textPrimary: AppPalette.neutral900,
    textSecondary: AppPalette.neutral500,
    textDisabled: AppPalette.neutral300,
    background: AppPalette.background,
    backgroundMuted: AppPalette.neutral100,
    border: AppPalette.neutral300,
    shadow: Color(0x1A000000),
  );

  static const AppCustomColors _darkCustomColors = AppCustomColors(
    brand: AppColorFamily(
      base: AppPalette.secondary,
      soft: Color(0xFF58D5BA),
      subtle: Color(0xFF0E2A25),
    ),
    accent: AppColorFamily(
      base: AppPalette.accent,
      soft: Color(0xFFFFB680),
      subtle: Color(0xFF2A1B0E),
    ),
    success: AppColorFamily(
      base: AppPalette.success,
      soft: Color(0xFF86EFAC),
      subtle: Color(0xFF0E2417),
    ),
    warning: AppColorFamily(
      base: AppPalette.warning,
      soft: Color(0xFFFDE68A),
      subtle: Color(0xFF2A250C),
    ),
    error: AppColorFamily(
      base: AppPalette.error,
      soft: Color(0xFFFCA5A5),
      subtle: Color(0xFF2A1010),
    ),
    textPrimary: AppPalette.neutral100,
    textSecondary: AppPalette.neutral300,
    textDisabled: AppPalette.neutral500,
    background: AppPalette.backgroundDark,
    backgroundMuted: Color(0xFF0F172A),
    border: AppPalette.neutral700,
    shadow: Color(0x8A000000),
  );
}
