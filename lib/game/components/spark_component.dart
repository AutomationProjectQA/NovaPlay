import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/game/physics/physics_constants.dart';

/// Renders the Nova spark and a short fading trail behind it. Its position is
/// driven each frame by the physics `SparkBody`; this component is pure visuals
/// (docs/ARCHITECTURE.md §8.6).
class SparkComponent extends PositionComponent {
  SparkComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 40);

  static const int _trailLength = 14;
  final Queue<Vector2> _trail = Queue<Vector2>();

  final Paint _corePaint = Paint()..color = AppColors.nova500;
  final Paint _glowPaint = Paint()
    ..color = AppColors.nova500.withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  /// Records the current position into the trail history.
  void pushTrail(Vector2 worldPosition) {
    _trail.addLast(worldPosition.clone());
    while (_trail.length > _trailLength) {
      _trail.removeFirst();
    }
  }

  /// Clears the trail (e.g. when resetting for a new shot).
  void resetTrail() => _trail.clear();

  @override
  void render(Canvas canvas) {
    // Trail: oldest faint, newest bright. Drawn in the spark's local space, so
    // convert stored world points relative to the component position.
    var i = 0;
    for (final point in _trail) {
      final t = i / _trailLength;
      final local = point - position;
      canvas.drawCircle(
        Offset(local.x, local.y),
        PhysicsConstants.sparkRadius * (0.3 + 0.7 * t),
        Paint()..color = AppColors.nova400.withValues(alpha: 0.08 + 0.20 * t),
      );
      i++;
    }
    canvas
      ..drawCircle(Offset.zero, PhysicsConstants.sparkRadius * 2.2, _glowPaint)
      ..drawCircle(Offset.zero, PhysicsConstants.sparkRadius, _corePaint);
  }
}
