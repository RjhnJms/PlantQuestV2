import 'package:flutter/material.dart';

import '../app/transitions.dart';
import 'app_colors.dart';
import 'app_text.dart';

/// Material 3 theme built only from [AppColors] and [AppText].
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.leaf,
      onPrimary: AppColors.text,
      primaryContainer: AppColors.leafTint,
      onPrimaryContainer: AppColors.text,
      secondary: AppColors.sky,
      onSecondary: AppColors.text,
      secondaryContainer: AppColors.skyTint,
      onSecondaryContainer: AppColors.text,
      tertiary: AppColors.grapeInk,
      onTertiary: AppColors.onGrape,
      tertiaryContainer: AppColors.grapeTint,
      onTertiaryContainer: AppColors.text,
      // There is no harsh red in PlantQuest: "errors" are gentle coral.
      error: AppColors.coral,
      onError: AppColors.text,
      errorContainer: AppColors.coralTint,
      onErrorContainer: AppColors.text,
      surface: AppColors.card,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerLowest: AppColors.card,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.border,
      surfaceContainerHighest: AppColors.track,
      outline: AppColors.borderDeep,
      outlineVariant: AppColors.border,
      shadow: AppColors.borderDeep,
      scrim: AppColors.text,
      inverseSurface: AppColors.text,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.leafLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: AppColors.background,
      // Chunky widgets give their own press feedback, so no ink ripples.
      splashFactory: NoSplash.splashFactory,
      highlightColor: const Color(0x00000000),
      textTheme: const TextTheme(
        displayLarge: AppText.display,
        headlineMedium: AppText.title,
        titleLarge: AppText.heading,
        bodyLarge: AppText.body,
        bodyMedium: AppText.body,
        bodySmall: AppText.bodySmall,
        labelLarge: AppText.button,
        labelMedium: AppText.label,
      ),
      iconTheme: const IconThemeData(color: AppColors.text, size: 26),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PlayfulPageTransitionsBuilder(),
          TargetPlatform.iOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.windows: PlayfulPageTransitionsBuilder(),
          TargetPlatform.macOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.linux: PlayfulPageTransitionsBuilder(),
          TargetPlatform.fuchsia: PlayfulPageTransitionsBuilder(),
        },
      ),
    );
  }
}
