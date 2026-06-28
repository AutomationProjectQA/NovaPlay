import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Draws a soft guide from the slingshot anchor toward the suggested target
/// (the nearest unlit star) when the player asks for a hint
/// (docs/GAME_DESIGN.md hint system). Visual only.
class HintComponent extends PositionComponent {
  HintComponent({required this.origin}) : super(priority: 36);

  final Vector2 origin;

  /// The target to point at, or null to hide the hint.
  Vector2? target;

  static final Paint _line = Paint()
    ..color = AppColors.nova400.withValues(alpha: 0.5)
    ..strokeWidth = 0.6
    ..strokeCap = StrokeCap.round;
  static final Paint _ring = Paint()
    ..color = AppColors.nova500.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  @override
  void render(Canvas canvas) {
    final to = target;
    if (to == null) return;
    canvas
      ..drawLine(Offset(origin.x, origin.y), Offset(to.x, to.y), _line)
      ..drawCircle(Offset(to.x, to.y), 5, _ring);
  }
}
