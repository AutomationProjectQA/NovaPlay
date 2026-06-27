import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:vector_math/vector_math.dart';

/// The single dynamic body in the world — the launched Nova spark
/// (docs/ARCHITECTURE.md §8.2). Pure data; the engine integrates it.
class SparkBody {
  SparkBody({
    required this.position,
    Vector2? velocity,
    this.radius = PhysicsConstants.sparkRadius,
    this.alive = true,
  }) : velocity = velocity ?? Vector2.zero();

  final Vector2 position;
  final Vector2 velocity;
  final double radius;

  /// False once the spark is consumed by a black hole.
  bool alive;

  double get speed => velocity.length;

  /// A deep copy, used by the trajectory preview to simulate without mutating
  /// the live spark.
  SparkBody clone() => SparkBody(
    position: position.clone(),
    velocity: velocity.clone(),
    radius: radius,
    alive: alive,
  );
}
