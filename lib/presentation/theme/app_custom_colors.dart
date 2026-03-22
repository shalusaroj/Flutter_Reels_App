import 'package:flutter/material.dart';

@immutable
class AppColorFamily {
  const AppColorFamily({
    required this.base,
    required this.soft,
    required this.subtle,
  });

  final Color base;
  final Color soft;
  final Color subtle;

  static AppColorFamily? lerp(AppColorFamily? a, AppColorFamily? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }

    return AppColorFamily(
      base: Color.lerp(a.base, b.base, t)!,
      soft: Color.lerp(a.soft, b.soft, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
    );
  }
}

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.brand,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.background,
    required this.backgroundMuted,
    required this.border,
    required this.shadow,
  });

  final AppColorFamily brand;
  final AppColorFamily accent;
  final AppColorFamily success;
  final AppColorFamily warning;
  final AppColorFamily error;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color background;
  final Color backgroundMuted;
  final Color border;
  final Color shadow;

  @override
  AppCustomColors copyWith({
    AppColorFamily? brand,
    AppColorFamily? accent,
    AppColorFamily? success,
    AppColorFamily? warning,
    AppColorFamily? error,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? background,
    Color? backgroundMuted,
    Color? border,
    Color? shadow,
  }) {
    return AppCustomColors(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      background: background ?? this.background,
      backgroundMuted: backgroundMuted ?? this.backgroundMuted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(
    covariant ThemeExtension<AppCustomColors>? other,
    double t,
  ) {
    if (other is! AppCustomColors) {
      return this;
    }

    return AppCustomColors(
      brand: AppColorFamily.lerp(brand, other.brand, t)!,
      accent: AppColorFamily.lerp(accent, other.accent, t)!,
      success: AppColorFamily.lerp(success, other.success, t)!,
      warning: AppColorFamily.lerp(warning, other.warning, t)!,
      error: AppColorFamily.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundMuted: Color.lerp(backgroundMuted, other.backgroundMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
