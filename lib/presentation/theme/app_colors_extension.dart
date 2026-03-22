import 'package:flutter/material.dart';

import 'app_custom_colors.dart';
import 'app_palette.dart';

extension AppColorsExtension on BuildContext {
  AppColorsContainer get colors => AppColorsContainer(this);
}

@immutable
class AppColorsContainer {
  const AppColorsContainer(this._context);

  final BuildContext _context;

  ColorScheme get _scheme => Theme.of(_context).colorScheme;
  AppCustomColors get _custom =>
      Theme.of(_context).extension<AppCustomColors>()!;

  Color get primary => _scheme.primary;
  Color get onPrimary => _scheme.onPrimary;
  Color get secondary => _scheme.secondary;
  Color get onSecondary => _scheme.onSecondary;
  Color get tertiary => _scheme.tertiary;
  Color get onTertiary => _scheme.onTertiary;
  Color get surface => _scheme.surface;
  Color get onSurface => _scheme.onSurface;
  Color get outline => _scheme.outline;

  AppColorFamily get brand => _custom.brand;
  AppColorFamily get accent => _custom.accent;
  AppColorFamily get success => _custom.success;
  AppColorFamily get warning => _custom.warning;
  AppColorFamily get error => _custom.error;

  Color get textPrimary => _custom.textPrimary;
  Color get textSecondary => _custom.textSecondary;
  Color get textDisabled => _custom.textDisabled;
  Color get background => _custom.background;
  Color get backgroundMuted => _custom.backgroundMuted;
  Color get border => _custom.border;
  Color get shadow => _custom.shadow;

  // Reels-specific semantic tokens
  Color get transparent => AppPalette.transparent;
  Color get reelsBackground => AppPalette.backgroundDark;
  Color get reelsForeground => AppPalette.white;
  Color get reelsForegroundMuted => AppPalette.neutral300;
  Color get reelsOverlay => AppPalette.neutral900;
  Color get reelsLikeActive => _custom.error.base;
  Color get reelsFailureBanner => _custom.error.base.withValues(alpha: 0.75);
  Color get reelsShimmerBase => AppPalette.neutral900.withValues(alpha: 0.85);
  Color get reelsShimmerHighlight =>
      AppPalette.neutral700.withValues(alpha: 0.85);
}
