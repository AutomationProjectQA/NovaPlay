import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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

  /// A quick scale "pop" celebrating the moment the star lights
  /// (docs/DESIGN_SYSTEM.md §5). No-op under reduced motion.
  void pop({required bool reducedMotion}) {
    if (reducedMotion) return;
    // Fire-and-forget effect; Flame manages its lifecycle.
    // ignore: discarded_futures
    add(
      ScaleEffect.by(
        Vector2.all(1.4),
        EffectController(
          duration: 0.12,
          reverseDuration: 0.12,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  // Cached paints — render runs every frame and must not allocate
  // (docs/PERFORMANCE.md).
  static final Paint _litGlow = Paint()
    ..color = AppColors.nova500.withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  static final Paint _litBody = Paint()..color = AppColors.starLit;
  static final Paint _dimFill = Paint()
    ..color = AppColors.starDim.withValues(alpha: 0.4);
  static final Paint _dimStroke = Paint()
    ..color = AppColors.starDim
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6;

  @override
  void render(Canvas canvas) {
    if (_lit) {
      canvas
        ..drawCircle(Offset.zero, radius * 2, _litGlow)
        ..drawCircle(Offset.zero, radius, _litBody);
    } else {
      canvas
        ..drawCircle(Offset.zero, radius, _dimFill)
        ..drawCircle(Offset.zero, radius, _dimStroke);
    }
  }
}
