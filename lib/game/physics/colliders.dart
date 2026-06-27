import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:vector_math/vector_math.dart';

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
