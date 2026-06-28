import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Draws the dotted aim preview while the player is dragging. The points come
/// from a headless run of the physics integrator (docs/ARCHITECTURE.md §8.4),
/// so the preview matches the real shot exactly.
class TrajectoryPreview extends PositionComponent {
  TrajectoryPreview() : super(priority: 35);

  /// The previewed path (world-space points). Empty hides the preview.
  List<Vector2> points = const [];

  /// Clears the preview.
  void clear() => points = const [];

  // Reused for every dot (recolored per point) — no per-frame allocation.
  final Paint _paint = Paint();

  @override
  void render(Canvas canvas) {
    if (points.length < 2) return;
    for (var i = 0; i < points.length; i++) {
      final fade = 1 - i / points.length;
      _paint.color = AppColors.nova400.withValues(alpha: 0.5 * fade);
      canvas.drawCircle(Offset(points[i].x, points[i].y), 0.7, _paint);
    }
  }
}
