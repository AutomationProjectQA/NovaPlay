import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// A dim star target. Lights up when the spark passes through it.
/// Full collision/lighting logic arrives in the engine sprint (Sprint 8).
class StarComponent extends CircleComponent {
  StarComponent({required super.position})
    : super(
        radius: 10,
        anchor: Anchor.center,
        paint: Paint()..color = AppColors.starDim,
      );

  bool _lit = false;

  /// Whether this star has been lit.
  bool get isLit => _lit;

  /// Lights the star (changes its color). Idempotent.
  void light() {
    if (_lit) return;
    _lit = true;
    paint.color = AppColors.starLit;
  }
}
