import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/game/physics/colliders.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/physics/physics_engine.dart';
import 'package:novaplay/game/physics/spark_body.dart';
import 'package:vector_math/vector_math.dart';

const _dt = PhysicsConstants.fixedDt;

void main() {
  group('PhysicsEngine reflection', () {
    test('spark bounces off a vertical wall (x velocity flips sign)', () {
      // Wall along x = 50 (vertical segment). Spark heading +x into it.
      final engine = PhysicsEngine(
        segments: [SegmentCollider(Vector2(50, 0), Vector2(50, 100))],
      );
      final spark = SparkBody(
        position: Vector2(40, 50),
        velocity: Vector2(120, 0),
      );

      var bounced = false;
      for (var i = 0; i < 240; i++) {
        if (engine.step(spark, _dt).bounced) bounced = true;
      }

      // After hitting the wall it must be travelling back in -x.
      expect(spark.velocity.x, lessThan(0));
      // And it must not have tunnelled through the wall.
      expect(spark.position.x, lessThanOrEqualTo(50));
      // The bounce must have been reported (drives SFX/haptics).
      expect(bounced, isTrue);
    });

    test('fast spark does not tunnel through a thin wall in one step', () {
      final engine = PhysicsEngine(
        segments: [SegmentCollider(Vector2(50, 0), Vector2(50, 100))],
      );
      // Very fast: without swept collision it would skip past x=50 in one step.
      final spark = SparkBody(
        position: Vector2(49, 50),
        velocity: Vector2(5000, 0),
      );
      engine.step(spark, _dt);
      expect(spark.position.x, lessThanOrEqualTo(50));
    });
  });

  group('PhysicsEngine triggers', () {
    test('spark lights a star it passes through', () {
      final star = StarTarget(center: Vector2(60, 50));
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        stars: [star],
      );
      final spark = SparkBody(
        position: Vector2(40, 50),
        velocity: Vector2(80, 0),
      );

      var litIndex = -1;
      for (var i = 0; i < 240 && litIndex < 0; i++) {
        final events = engine.step(spark, _dt);
        if (events.starsLit.isNotEmpty) litIndex = events.starsLit.first;
      }

      expect(litIndex, 0);
      expect(star.isLit, isTrue);
    });

    test('black hole consumes the spark and ends the shot', () {
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        holes: [BlackHole(center: Vector2(60, 50))],
      );
      final spark = SparkBody(
        position: Vector2(40, 50),
        velocity: Vector2(80, 0),
      );

      var consumed = false;
      for (var i = 0; i < 240 && !consumed; i++) {
        consumed = engine.step(spark, _dt).enteredBlackHole;
      }
      expect(consumed, isTrue);
      expect(spark.alive, isFalse);
    });

    test('multi-hit star needs more than one touch', () {
      final star = StarTarget(center: Vector2(50, 50), hitsRequired: 2);
      expect(star.registerHit(), isFalse); // first touch: not yet lit
      expect(star.isLit, isFalse);
      expect(star.registerHit(), isTrue); // second touch: lit
      expect(star.isLit, isTrue);
    });
  });

  group('PhysicsEngine damping & preview', () {
    test('space drag bleeds speed over time', () {
      final engine = PhysicsEngine(segments: boardBoundaries());
      final spark = SparkBody(
        position: Vector2(50, 80),
        velocity: Vector2(0, 40),
      );
      final initial = spark.speed;
      for (var i = 0; i < 120; i++) {
        engine.step(spark, _dt);
      }
      expect(spark.speed, lessThan(initial));
    });

    test('previewPath returns a sampled, bounded trajectory', () {
      final engine = PhysicsEngine(segments: boardBoundaries());
      final start = SparkBody(
        position: Vector2(50, 80),
        velocity: Vector2(30, -30),
      );
      final path = engine.previewPath(start);
      expect(path.length, greaterThan(1));
      // The preview must not mutate the real spark.
      expect(start.position, Vector2(50, 80));
    });
  });
}
