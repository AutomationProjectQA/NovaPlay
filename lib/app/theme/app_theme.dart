import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/app/theme/nova_theme_extension.dart';

/// Assembles the single dark [ThemeData] used across NovaPlay.
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.nova500,
      onPrimary: AppColors.space900,
      secondary: AppColors.stardust,
      surface: AppColors.surfaceBase,
      onSurface: AppColors.onHigh,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.space800,
      textTheme: AppTypography.textTheme,
      extensions: <ThemeExtension<dynamic>>[NovaTheme.dark()],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.nova500,
          foregroundColor: AppColors.space900,
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
