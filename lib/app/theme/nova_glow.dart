import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Glow / elevation shadow tokens (docs/DESIGN_SYSTEM.md §1.5). NovaPlay uses
/// colored glows rather than dark drop-shadows to fit the luminous space theme.
abstract final class NovaGlow {
  /// Soft gold bloom under the primary spark / primary buttons.
  static List<BoxShadow> nova({double opacity = 0.4, double blur = 20}) => [
    BoxShadow(
      color: AppColors.nova500.withValues(alpha: opacity),
      blurRadius: blur,
      spreadRadius: 1,
    ),
  ];

  /// A sector-tinted glow used for level nodes and selected cards.
  static List<BoxShadow> sector(Color accent, {double opacity = 0.45}) => [
    BoxShadow(
      color: accent.withValues(alpha: opacity),
      blurRadius: 18,
      spreadRadius: 1,
    ),
  ];

  /// Neutral elevation for raised surfaces (subtle, dark).
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
