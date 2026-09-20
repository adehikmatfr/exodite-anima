import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.actionBg,
    onPrimary: c.actionFg,
    secondary: c.actionBg,
    onSecondary: c.actionFg,
    error: c.dangerFg,
    onError: c.dangerOnSolid,
    surface: c.surfaceBase,
    onSurface: c.textPrimary,
    surfaceContainerHighest: c.surfaceRaised,
    outline: c.borderStrong,
    outlineVariant: c.borderDefault,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.surfaceBase,
    fontFamily: AppType.ui,
    textTheme: const TextTheme(
      displaySmall: AppType.display,
      titleLarge: AppType.title,
      bodyLarge: AppType.body,
      bodyMedium: AppType.body,
      labelLarge: AppType.label,
      bodySmall: AppType.caption,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary),
    dividerColor: c.borderDefault,
    focusColor: c.focusRing,
    splashFactory: NoSplash.splashFactory,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpace.buttonHeight),
        backgroundColor: c.actionBg,
        foregroundColor: c.actionFg,
        textStyle: AppType.label,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpace.buttonHeight),
        foregroundColor: c.textPrimary,
        side: BorderSide(color: c.borderStrong),
        textStyle: AppType.label,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSpace.touchMin, AppSpace.touchMin),
        foregroundColor: c.actionBg,
        textStyle: AppType.label,
      ),
    ),
  );
}
