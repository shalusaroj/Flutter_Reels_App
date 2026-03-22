import 'package:flutter/material.dart';

import 'app_palette.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.labelSmall,
    required this.bodySmall,
    required this.bodyMedium,
    required this.titleMedium,
    required this.titleLarge,
    required this.headlineSmall,
    required this.displaySmall,
  });

  final TextStyle labelSmall;
  final TextStyle bodySmall;
  final TextStyle bodyMedium;
  final TextStyle titleMedium;
  final TextStyle titleLarge;
  final TextStyle headlineSmall;
  final TextStyle displaySmall;

  factory AppTextStyles.fromTokens() {
    const base = TextStyle(
      fontFamily: 'Open Sans',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: AppPalette.neutral700,
      decoration: TextDecoration.none,
    );

    return AppTextStyles(
      labelSmall: base.copyWith(fontSize: 10, height: 1.4, letterSpacing: 0.2),
      bodySmall: base.copyWith(fontSize: 12, height: 1.33, letterSpacing: 0.18),
      bodyMedium: base.copyWith(
        fontSize: 14,
        height: 1.42,
        letterSpacing: 0.16,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        height: 1.5,
        letterSpacing: 0.12,
      ),
      titleLarge: base.copyWith(fontSize: 20, height: 1.4, letterSpacing: 0.08),
      headlineSmall: base.copyWith(fontSize: 24, height: 1.3),
      displaySmall: base.copyWith(
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.4,
      ),
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? labelSmall,
    TextStyle? bodySmall,
    TextStyle? bodyMedium,
    TextStyle? titleMedium,
    TextStyle? titleLarge,
    TextStyle? headlineSmall,
    TextStyle? displaySmall,
  }) {
    return AppTextStyles(
      labelSmall: labelSmall ?? this.labelSmall,
      bodySmall: bodySmall ?? this.bodySmall,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      titleMedium: titleMedium ?? this.titleMedium,
      titleLarge: titleLarge ?? this.titleLarge,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      displaySmall: displaySmall ?? this.displaySmall,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }

    return AppTextStyles(
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
    );
  }
}

extension AppTextStyleHelpers on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get appTextStyles =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.fromTokens();
}
