import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/components/spark_component.dart';
import 'package:novaplay/game/components/trajectory_preview.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/physics/physics_engine.dart';
import 'package:novaplay/game/physics/spark_body.dart';
import 'package:novaplay/game/session/game_session_controller.dart';
import 'package:novaplay/game/session/game_snapshot.dart';
import 'package:novaplay/game/session/game_state.dart';
import 'package:novaplay/game/world/level_builder.dart';

/// The NovaPlay Flame world (docs/ARCHITECTURE.md §8). Owns the physics engine
/// and the single spark, runs a fixed-timestep loop for determinism, handles
/// drag-to-aim with a live trajectory preview, and reports shot outcomes to the
/// [GameSessionController]. Input is fed in as logical board coordinates from
/// the Flutter gesture layer (`GameScreen`).
class NovaGame extends FlameGame {
  NovaGame({required this.level, required this.controller, this.snapshot})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: PhysicsConstants.boardWidth,
          height: PhysicsConstants.boardHeight,
        ),
      );

  final LevelDefinition level;
  final GameSessionController controller;

  /// A snapshot to resume from (pause/kill recovery), if any.
  final GameSnapshot? snapshot;

  /// Minimum drag length (logical units) before a launch is registered.
  static const double _minDrag = 4;

  late final PhysicsEngine _engine;
  late final LevelField _field;
  late final SparkComponent _sparkComponent;
  late final TrajectoryPreview _preview;
  late final Vector2 _anchor;

  SparkBody _spark = SparkBody(position: Vector2.zero());
  bool _shotActive = false;
  bool _aiming = false;
  Vector2? _aimPoint;
  double _accumulator = 0;
  double _shotTime = 0;

  @override
  Color backgroundColor() => AppColors.space900;

  @override
  Future<void> onLoad() async {
    camera.world = world;
    camera.viewfinder.position = Vector2(
      PhysicsConstants.boardWidth / 2,
      PhysicsConstants.boardHeight / 2,
    );

    _field = buildLevelField(level);
    _anchor = _field.launchAnchor;
    _engine = PhysicsEngine(
      segments: _field.segments,
      wells: _field.wells,
      holes: _field.holes,
      stars: _field.stars,
      portals: _field.portals,
    );

    _spark = SparkBody(position: _anchor.clone());
    _preview = TrajectoryPreview();
    _sparkComponent = SparkComponent(position: _anchor.clone());

    await world.addAll(_field.visuals);
    await world.add(_preview);
    await world.add(_sparkComponent);

    _applySnapshot();
  }

  void _applySnapshot() {
    final snap = snapshot;
    if (snap == null) return;
    for (final index in snap.litStarIndices) {
      if (index < 0 || index >= _field.stars.length) continue;
      _field.stars[index].hits = _field.stars[index].hitsRequired;
      _field.starComponents[index].light();
    }
  }

  /// Indices of stars currently lit — used to build a resume snapshot.
  List<int> litStarIndices() {
    final result = <int>[];
    for (var i = 0; i < _field.stars.length; i++) {
      if (_field.stars[i].isLit) result.add(i);
    }
    return result;
  }

  // ── Input (logical board coordinates, fed from GameScreen) ──

  void aimStart(Vector2 point) {
    if (_shotActive || controller.value.status != GameStatus.aiming) return;
    _aiming = true;
    _aimPoint = point;
    _refreshPreview();
  }

  void aimUpdate(Vector2 point) {
    if (!_aiming) return;
    _aimPoint = point;
    _refreshPreview();
  }

  void aimEnd() {
    if (!_aiming) return;
    _aiming = false;
    _preview.clear();
    _launch();
  }

  // ── Aiming helpers ──

  Vector2? _launchVelocity() {
    final aim = _aimPoint;
    if (aim == null) return null;
    final drag = aim - _anchor;
    final length = drag.length;
    if (length < _minDrag) return null;
    // Slingshot: launch opposite the pull, power scaled by drag length.
    final direction = (-drag)..normalize();
    final power =
        (length / PhysicsConstants.maxDragLength).clamp(0.0, 1.0) *
        PhysicsConstants.maxLaunchSpeed;
    return direction * power;
  }

  void _refreshPreview() {
    final velocity = _launchVelocity();
    if (velocity == null) {
      _preview.clear();
      return;
    }
    _preview.points = _engine.previewPath(
      SparkBody(position: _anchor.clone(), velocity: velocity),
    );
  }

  void _launch() {
    final velocity = _launchVelocity();
    if (velocity == null) return;
    controller.beginShot();
    _spark = SparkBody(position: _anchor.clone(), velocity: velocity);
    _sparkComponent
      ..position.setFrom(_anchor)
      ..resetTrail();
    _shotActive = true;
    _shotTime = 0;
    _accumulator = 0;
  }

  // ── Fixed-timestep simulation (docs/ARCHITECTURE.md §8.8) ──

  @override
  void update(double dt) {
    super.update(dt);
    if (!_shotActive || controller.value.status == GameStatus.paused) return;

    _accumulator += dt.clamp(0, PhysicsConstants.maxFrame);
    while (_accumulator >= PhysicsConstants.fixedDt) {
      final events = _engine.step(_spark, PhysicsConstants.fixedDt);
      _accumulator -= PhysicsConstants.fixedDt;
      _shotTime += PhysicsConstants.fixedDt;

      if (events.starsLit.isNotEmpty) {
        for (final index in events.starsLit) {
          _field.starComponents[index].light();
        }
        controller.registerStarsLit(events.starsLit.length);
      }
      if (_shotEnded) break;
    }

    _sparkComponent.position.setFrom(_spark.position);
    _sparkComponent.pushTrail(_spark.position);

    if (_shotEnded) _finalizeShot();
  }

  bool get _shotEnded =>
      !_spark.alive ||
      _spark.speed < PhysicsConstants.minSpeed ||
      _shotTime > PhysicsConstants.maxShotSeconds ||
      controller.value.isOver;

  void _finalizeShot() {
    _shotActive = false;
    if (controller.value.isOver) return; // won mid-flight (or already resolved)

    controller.endShot();
    if (controller.value.isOver) return; // that shot was the losing one

    // Reset the spark to the slingshot for the next shot.
    _spark = SparkBody(position: _anchor.clone());
    _sparkComponent
      ..position.setFrom(_anchor)
      ..resetTrail();
  }
}
