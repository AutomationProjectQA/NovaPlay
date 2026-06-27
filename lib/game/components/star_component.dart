import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// A dim star target rendered on the board. Visual only — the authoritative lit
/// state lives in the physics `StarTarget`; the engine calls [light] when the
/// spark touches it (docs/ARCHITECTURE.md §8.2, §8.6).
class StarComponent extends PositionComponent {
  StarComponent({required Vector2 position, this.radius = 3})
    : super(position: position, anchor: Anchor.center, priority: 30);

  final double radius;
  bool _lit = false;

  bool get isLit => _lit;

  /// Lights the star. Idempotent.
  void light() => _lit = true;

  /// Sets the lit state directly (used by undo/restart to re-dim a star).
  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void setLit(bool value) => _lit = value;

  @override
  void render(Canvas canvas) {
    if (_lit) {
      canvas
        ..drawCircle(
          Offset.zero,
          radius * 2,
          Paint()
            ..color = AppColors.nova500.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        )
        ..drawCircle(
          Offset.zero,
          radius,
          Paint()..color = AppColors.starLit,
        );
    } else {
      canvas
        ..drawCircle(
          Offset.zero,
          radius,
          Paint()..color = AppColors.starDim.withValues(alpha: 0.4),
        )
        ..drawCircle(
          Offset.zero,
          radius,
          Paint()
            ..color = AppColors.starDim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
    }
  }
}
