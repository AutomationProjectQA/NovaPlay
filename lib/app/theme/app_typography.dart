import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Type scale for NovaPlay (docs/DESIGN_SYSTEM.md typography).
///
/// Uses the platform default family for now; the branded display font (e.g.
/// "Sora") is wired in a later sprint via pubspec `fonts:`.
abstract final class AppTypography {
  // The branded display font (e.g. 'Sora') is bundled in a later sprint; until
  // then styles use the platform default family.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.onHigh,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.onHigh,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.onHigh,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.4,
    color: AppColors.onHigh,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: AppColors.onMedium,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.onHigh,
  );

  /// Assembles a Material [TextTheme] from the tokens above.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineMedium: headlineMedium,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: labelLarge,
  );
}
