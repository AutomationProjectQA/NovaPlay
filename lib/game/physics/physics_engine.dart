import 'dart:math' as math;

import 'package:novaplay/game/physics/colliders.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/physics/spark_body.dart';
import 'package:vector_math/vector_math.dart';

/// What happened to the spark during one [PhysicsEngine.step].
class StepEvents {
  StepEvents();

  /// Indices (into [PhysicsEngine.stars]) of stars newly lit this step.
  final List<int> starsLit = [];

  /// True if the spark entered a black hole this step (shot ends).
  bool enteredBlackHole = false;

  /// True if the spark teleported through a portal this step.
  bool usedPortal = false;
}

/// The deterministic spark physics core (docs/ARCHITECTURE.md §8.3, §8.7).
///
/// Pure Dart — no Flame/Flutter — so it is fully headless-testable. Holds the
/// static field for one level and integrates the single dynamic [SparkBody] with
/// swept (anti-tunnelling) circle-vs-segment collisions, radial gravity wells,
/// and overlap triggers (stars, portals, black holes).
class PhysicsEngine {
  PhysicsEngine({
    required this.segments,
    this.wells = const [],
    this.holes = const [],
    this.stars = const [],
    this.portals = const [],
  });

  final List<SegmentCollider> segments;
  final List<GravityWell> wells;
  final List<BlackHole> holes;
  final List<StarTarget> stars;
  final List<Portal> portals;

  static const double _eps = 1e-6;

  /// Advances [spark] by one fixed step, resolving collisions then triggers.
  StepEvents step(SparkBody spark, double dt) {
    final events = StepEvents();
    if (!spark.alive) return events;

    _advance(spark, dt);
    _resolveTriggers(spark, events);
    return events;
  }

  /// Integration + collision only (no trigger side effects). Shared by [step]
  /// and the trajectory preview so both behave identically.
  void _advance(SparkBody spark, double dt) {
    // Gravity wells: radial pull, stronger near the centre, zero past the radius.
    final accel = Vector2.zero();
    for (final well in wells) {
      final toCenter = well.center - spark.position;
      final dist = toCenter.length;
      if (dist > _eps && dist < well.radius) {
        final falloff = 1 - dist / well.radius;
        accel.add(toCenter.normalized() * (well.strength * falloff));
      }
    }
    spark.velocity.add(accel * dt);

    // Space drag so every shot terminates.
    spark.velocity.scale(
      math.pow(PhysicsConstants.dampingPerSecond, dt).toDouble(),
    );

    // Move with reflective bounces, sweeping the path to avoid tunnelling.
    var remaining = dt;
    var bounces = 0;
    while (remaining > _eps && bounces <= PhysicsConstants.maxBouncesPerStep) {
      final p0 = spark.position.clone();
      final p1 = p0 + spark.velocity * remaining;
      final hit = _nearestHit(p0, p1);
      if (hit == null) {
        spark.position.setFrom(p1);
        break;
      }
      // Park the spark just off the surface on the incoming side.
      spark.position
        ..setFrom(hit.point)
        ..add(hit.normal * spark.radius);
      // Reflect about the surface normal, applying the collider's bounce gain.
      _reflect(spark.velocity, hit.normal);
      spark.velocity.scale(hit.bounce);
      remaining *= 1 - hit.t;
      bounces++;
    }
  }

  void _resolveTriggers(SparkBody spark, StepEvents events) {
    for (final hole in holes) {
      if (spark.position.distanceTo(hole.center) < hole.radius + spark.radius) {
        spark.alive = false;
        events.enteredBlackHole = true;
        return;
      }
    }
    for (final portal in portals) {
      if (spark.position.distanceTo(portal.entry) < portal.radius) {
        spark.position.setFrom(portal.exit);
        events.usedPortal = true;
        break;
      }
    }
    for (var i = 0; i < stars.length; i++) {
      final star = stars[i];
      if (star.isLit) continue;
      if (spark.position.distanceTo(star.center) < star.radius + spark.radius) {
        if (star.registerHit()) events.starsLit.add(i);
      }
    }
  }

  /// Finds the nearest segment the path p0→p1 crosses, if any.
  _Hit? _nearestHit(Vector2 p0, Vector2 p1) {
    final r = p1 - p0;
    _Hit? nearest;
    for (final seg in segments) {
      final s = seg.b - seg.a;
      final denom = _cross(r, s);
      if (denom.abs() < _eps) continue; // parallel
      final ap = seg.a - p0;
      final t = _cross(ap, s) / denom; // along the path
      final u = _cross(ap, r) / denom; // along the segment
      if (t < _eps || t > 1 || u < 0 || u > 1) continue;
      if (nearest != null && t >= nearest.t) continue;
      var n = seg.normal;
      if (n.dot(r) > 0) n = -n; // face the incoming side
      nearest = _Hit(t: t, point: p0 + r * t, normal: n, bounce: seg.bounce);
    }
    return nearest;
  }

  /// Reflects [v] about unit normal [n] in place: v -= 2 (v·n) n.
  void _reflect(Vector2 v, Vector2 n) {
    final d = 2 * v.dot(n);
    v.sub(n * d);
  }

  double _cross(Vector2 a, Vector2 b) => a.x * b.y - a.y * b.x;

  /// Simulates a clone of [start] through the static field to produce the dotted
  /// aim preview (docs/ARCHITECTURE.md §8.4). Stops at a black hole, when the
  /// spark settles, or after the step budget. No trigger side effects.
  List<Vector2> previewPath(
    SparkBody start, {
    int maxSteps = PhysicsConstants.previewMaxSteps,
    int sampleEvery = PhysicsConstants.previewSampleEvery,
  }) {
    final ghost = start.clone();
    final points = <Vector2>[ghost.position.clone()];
    for (var i = 0; i < maxSteps; i++) {
      _advance(ghost, PhysicsConstants.fixedDt);
      if (i % sampleEvery == 0) points.add(ghost.position.clone());
      if (ghost.speed < PhysicsConstants.minSpeed) break;
      if (_inAnyBlackHole(ghost)) break;
    }
    return points;
  }

  bool _inAnyBlackHole(SparkBody spark) {
    for (final hole in holes) {
      if (spark.position.distanceTo(hole.center) < hole.radius + spark.radius) {
        return true;
      }
    }
    return false;
  }
}

class _Hit {
  _Hit({
    required this.t,
    required this.point,
    required this.normal,
    required this.bounce,
  });

  final double t;
  final Vector2 point;
  final Vector2 normal;
  final double bounce;
}
