import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// The single victory spectacle: a soft light bloom that expands from the board
/// centre and fades out, then removes itself (docs/UI_GUIDELINES.md §3.6 "the
/// one spectacle"). Skipped entirely under reduced motion.
class BloomComponent extends PositionComponent {
  BloomComponent({required super.position})
    : super(anchor: Anchor.center, priority: 50);

  static const double _duration = 0.8;
  double _elapsed = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    final radius = 8 + progress * 130;
    final alpha = (1 - progress) * 0.4;
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()..color = AppColors.nova500.withValues(alpha: alpha),
    );
  }
}
