import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// A straight reflective wall/asteroid bar between two points
/// (docs/ARCHITECTURE.md §8.2). Bumpers reuse this with [isBumper] true.
class WallComponent extends PositionComponent {
  WallComponent({
    required this.start,
    required this.end,
    this.isBumper = false,
  }) : super(priority: 20);

  final Vector2 start;
  final Vector2 end;
  final bool isBumper;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isBumper ? AppColors.nova500 : AppColors.onMedium
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isBumper ? 2.4 : 1.6;
    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(end.x, end.y),
      paint,
    );
  }
}

/// A faint ring marking a gravity well's influence radius.
class GravityWellComponent extends PositionComponent {
  GravityWellComponent({required Vector2 center, required this.radius})
    : super(position: center, anchor: Anchor.center, priority: 18);

  final double radius;

  @override
  void render(Canvas canvas) {
    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = AppColors.sectorVoid.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      )
      ..drawCircle(
        Offset.zero,
        2,
        Paint()..color = AppColors.sectorVoid.withValues(alpha: 0.6),
      );
  }
}

/// A black-hole sink hazard.
class BlackHoleComponent extends PositionComponent {
  BlackHoleComponent({required Vector2 center, required this.radius})
    : super(position: center, anchor: Anchor.center, priority: 19);

  final double radius;

  @override
  void render(Canvas canvas) {
    canvas
      ..drawCircle(Offset.zero, radius, Paint()..color = AppColors.space900)
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = AppColors.stardust.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
  }
}

/// A paired portal ring (entry or exit).
class PortalComponent extends PositionComponent {
  PortalComponent({required Vector2 center, required this.radius})
    : super(position: center, anchor: Anchor.center, priority: 19);

  final double radius;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = AppColors.sectorNebula.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
