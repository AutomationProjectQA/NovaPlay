import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/game/physics/colliders.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/physics/physics_engine.dart';
import 'package:novaplay/game/physics/spark_body.dart';
import 'package:vector_math/vector_math.dart';

const _dt = PhysicsConstants.fixedDt;

void main() {
  group('reflective asteroid (CircleCollider)', () {
    test('a head-on spark bounces back off a static asteroid', () {
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        circles: [CircleCollider(home: Vector2(60, 50), radius: 6)],
      );
      final spark = SparkBody(
        position: Vector2(40, 50),
        velocity: Vector2(120, 0),
      );

      var bounced = false;
      for (var i = 0; i < 120 && !bounced; i++) {
        if (engine.step(spark, _dt).bounced) bounced = true;
      }
      expect(bounced, isTrue);
      // At the moment of the bounce it must be heading back in -x, not through.
      expect(spark.velocity.x, lessThan(0));
      expect(spark.position.distanceTo(Vector2(60, 50)), greaterThan(5));
    });

    test('a fast spark does not tunnel through a small asteroid', () {
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        circles: [CircleCollider(home: Vector2(50, 50), radius: 4)],
      );
      // Without swept circle collision this would skip past in one step.
      final spark = SparkBody(
        position: Vector2(30, 50),
        velocity: Vector2(6000, 0),
      );
      engine.step(spark, _dt);
      // It must have been deflected, not passed through to the far side.
      expect(spark.position.x, lessThan(54));
    });

    test('an off-centre hit deflects sideways (gains y velocity)', () {
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        circles: [CircleCollider(home: Vector2(60, 53), radius: 6)],
      );
      final spark = SparkBody(
        position: Vector2(40, 50),
        velocity: Vector2(120, 0),
      );
      for (var i = 0; i < 120; i++) {
        engine.step(spark, _dt);
      }
      // Hitting below centre pushes the spark upward (-y).
      expect(spark.velocity.y.abs(), greaterThan(0));
    });
  });

  group('ColliderMotion (moving obstacle)', () {
    test('position oscillates between home and target', () {
      final motion = ColliderMotion(to: Vector2(80, 50), period: 4);
      final home = Vector2(20, 50);
      // At t=0 the eased fraction is 0.5 (sin starts at 0), midpoint.
      expect(motion.positionAt(home, 0).x, closeTo(50, 0.001));
      // Quarter period → peak (fraction 1) → at target.
      expect(motion.positionAt(home, 1).x, closeTo(80, 0.001));
      // Three-quarter period → trough (fraction 0) → at home.
      expect(motion.positionAt(home, 3).x, closeTo(20, 0.001));
    });

    test('is deterministic and stays within the travel segment', () {
      final motion = ColliderMotion(to: Vector2(80, 50), period: 4);
      final home = Vector2(20, 50);
      for (var t = 0.0; t < 10; t += 0.13) {
        final x = motion.positionAt(home, t).x;
        expect(x, inInclusiveRange(20 - 1e-6, 80 + 1e-6));
        expect(motion.positionAt(home, t).x, motion.positionAt(home, t).x);
      }
    });

    test('previewPath does not advance the engine clock', () {
      final engine = PhysicsEngine(
        segments: boardBoundaries(),
        circles: [
          CircleCollider(
            home: Vector2(50, 50),
            radius: 5,
            motion: ColliderMotion(to: Vector2(70, 50), period: 2),
          ),
        ],
      );
      final before = engine.elapsed;
      engine.previewPath(
        SparkBody(position: Vector2(50, 80), velocity: Vector2(10, -40)),
      );
      expect(engine.elapsed, before); // preview is side-effect free
    });
  });
}
