import 'dart:math' as math;

import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:vector_math/vector_math.dart';

/// Sinusoidal there-and-back motion for a moving collider (docs/GAME_DESIGN.md).
/// A collider at `home` drifts toward [to] and back over [period] seconds, with
/// an optional [phase] offset (0–1). Pure + deterministic — position is a closed
/// function of time, so previews and replays match exactly.
class ColliderMotion {
  ColliderMotion({required this.to, required this.period, this.phase = 0});

  final Vector2 to;
  final double period;
  final double phase;

  /// The eased 0→1→0 position fraction at [time] seconds.
  double fraction(double time) {
    if (period <= 0) return 0;
    return (math.sin(2 * math.pi * (time / period + phase)) + 1) / 2;
  }

  /// The interpolated position of a collider whose home is [home] at [time].
  Vector2 positionAt(Vector2 home, double time) =>
      home + (to - home) * fraction(time);
}

/// A round reflective obstacle — an asteroid (docs/CONCEPT.md §5). The spark
/// bounces off its surface (circle reflection). When [motion] is set the asteroid
/// drifts, becoming a moving obstacle. [bounce] is the energy multiplier on hit.
class CircleCollider {
  CircleCollider({
    required this.home,
    required this.radius,
    this.bounce = 1.0,
    this.motion,
  });

  final Vector2 home;
  final double radius;
  final double bounce;
  final ColliderMotion? motion;

  bool get isMoving => motion != null;

  /// The asteroid's centre at [time] seconds (constant when static).
  Vector2 centerAt(double time) =>
      motion == null ? home : motion!.positionAt(home, time);
}

/// A reflective line segment — a wall edge, asteroid face, or bumper
/// (docs/ARCHITECTURE.md §8.2). [bounce] is the energy multiplier on reflection
/// (1.0 = wall, >1.0 = bumper).
class SegmentCollider {
  SegmentCollider(this.a, this.b, {this.bounce = 1.0});

  final Vector2 a;
  final Vector2 b;
  final double bounce;

  /// Unit normal of the segment (perpendicular to a→b).
  Vector2 get normal {
    final dir = b - a;
    return Vector2(-dir.y, dir.x)..normalize();
  }
}

/// A radial force field that curves the spark's path toward [center] while it is
/// within [radius] (docs/CONCEPT.md §5 gravity well).
class GravityWell {
  GravityWell({
    required this.center,
    required this.radius,
    required this.strength,
  });

  final Vector2 center;
  final double radius;
  final double strength;
}

/// A sink hazard: entering its event radius consumes the spark and ends the shot.
class BlackHole {
  BlackHole({required this.center, this.radius = 4});

  final Vector2 center;
  final double radius;
}

/// A dim star target. Lights when the spark overlaps it; multi-hit stars need
/// [hitsRequired] touches (docs/GAME_DESIGN.md).
class StarTarget {
  StarTarget({
    required this.center,
    this.radius = 3,
    this.hitsRequired = 1,
  });

  final Vector2 center;
  final double radius;
  final int hitsRequired;

  int hits = 0;

  bool get isLit => hits >= hitsRequired;

  /// Registers a touch; returns true if this touch newly lit the star.
  bool registerHit() {
    if (isLit) return false;
    hits++;
    return isLit;
  }
}

/// A paired wormhole: a spark entering [entry] emerges at [exit] keeping its
/// momentum (docs/CONCEPT.md §5 portal).
class Portal {
  Portal({required this.entry, required this.exit, this.radius = 3});

  final Vector2 entry;
  final Vector2 exit;
  final double radius;
}

/// Builds the four board-boundary walls so the spark stays in play.
List<SegmentCollider> boardBoundaries({
  double width = PhysicsConstants.boardWidth,
  double height = PhysicsConstants.boardHeight,
}) {
  final topLeft = Vector2(0, 0);
  final topRight = Vector2(width, 0);
  final bottomLeft = Vector2(0, height);
  final bottomRight = Vector2(width, height);
  return [
    SegmentCollider(topLeft, topRight),
    SegmentCollider(topRight, bottomRight),
    SegmentCollider(bottomRight, bottomLeft),
    SegmentCollider(bottomLeft, topLeft),
  ];
}
