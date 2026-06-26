import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/nova_theme_extension.dart';

/// Ergonomic theme accessors so widgets read tokens via `context.nova` and
/// `context.textTheme` (docs/DESIGN_SYSTEM.md §3).
extension NovaContextX on BuildContext {
  /// The NovaPlay brand/game tokens (gradient, spark, star, currency colors).
  NovaTheme get nova => Theme.of(this).extension<NovaTheme>()!;

  /// The active Material text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The active Material color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
