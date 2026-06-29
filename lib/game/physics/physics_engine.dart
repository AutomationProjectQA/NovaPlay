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

  /// True if the spark bounced off a wall/bumper this step.
  bool bounced = false;
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
    this.circles = const [],
  });

  final List<SegmentCollider> segments;
  final List<GravityWell> wells;
  final List<BlackHole> holes;
  final List<StarTarget> stars;
  final List<Portal> portals;

  /// Round reflective obstacles (asteroids); may be moving (docs/GAME_DESIGN.md).
  final List<CircleCollider> circles;

  static const double _eps = 1e-6;

  /// Elapsed simulated time, advanced only by [step] (not by previews), so
  /// moving colliders stay on a single deterministic timeline.
  double _elapsed = 0;

  /// The asteroid centre at [time], exposed so the Flame layer can move the
  /// matching visual in lock-step with the simulation.
  Vector2 circleCenterAt(int index, double time) =>
      circles[index].centerAt(time);

  /// Current simulated time (seconds since the engine was created).
  double get elapsed => _elapsed;

  /// Advances [spark] by one fixed step, resolving collisions then triggers.
  StepEvents step(SparkBody spark, double dt) {
    final events = StepEvents();
    if (!spark.alive) return events;

    events.bounced = _advance(spark, dt, _elapsed) > 0;
    _elapsed += dt;
    _resolveTriggers(spark, events);
    return events;
  }

  /// Integration + collision only (no trigger side effects). Returns the number
  /// of bounces resolved. Shared by [step] and the trajectory preview so both
  /// behave identically.
  int _advance(SparkBody spark, double dt, double time) {
    // Resolve moving-collider centres once for this step (movement per fixed
    // step is sub-pixel, so treating them as static within the step is exact
    // enough and keeps the swept solver simple).
    final solids = [
      for (final circle in circles)
        (
          c: circle.centerAt(time),
          r: circle.radius,
          bounce: circle.bounce,
        ),
    ];

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
      final hit = _nearestHit(p0, p1, spark.radius, solids);
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
    return bounces;
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

  /// Finds the nearest collider the path p0→p1 crosses, if any — segments first,
  /// then the round [solids] (asteroids), inflated by [sparkRadius].
  _Hit? _nearestHit(
    Vector2 p0,
    Vector2 p1,
    double sparkRadius,
    List<({Vector2 c, double r, double bounce})> solids,
  ) {
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
    // Swept point-vs-circle against each asteroid (inflated by the spark radius).
    for (final solid in solids) {
      final rSum = solid.r + sparkRadius;
      final f = p0 - solid.c;
      final inside = f.length2 - rSum * rSum;
      double t;
      Vector2 n;
      if (inside < -_eps) {
        // Already overlapping — bounce out immediately along the outward normal.
        t = _eps;
        n = f.length2 > _eps ? f.normalized() : Vector2(0, -1);
      } else {
        final a = r.dot(r);
        if (a < _eps) continue; // not moving
        final b = 2 * f.dot(r);
        final disc = b * b - 4 * a * inside;
        if (disc < 0) continue; // path misses the circle
        t = (-b - math.sqrt(disc)) / (2 * a); // entry root
        if (t < _eps || t > 1) continue;
        n = (p0 + r * t - solid.c)..normalize();
      }
      if (nearest != null && t >= nearest.t) continue;
      // Park on the asteroid surface; the caller adds another sparkRadius offset.
      nearest = _Hit(
        t: t,
        point: solid.c + n * solid.r,
        normal: n,
        bounce: solid.bounce,
      );
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
    // Advance a local clock so the preview reflects where moving asteroids will
    // be, without touching the engine's real [_elapsed].
    var time = _elapsed;
    for (var i = 0; i < maxSteps; i++) {
      _advance(ghost, PhysicsConstants.fixedDt, time);
      time += PhysicsConstants.fixedDt;
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
