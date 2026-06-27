import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/components/hint_component.dart';
import 'package:novaplay/game/components/spark_component.dart';
import 'package:novaplay/game/components/trajectory_preview.dart';
import 'package:novaplay/game/effects/bloom_component.dart';
import 'package:novaplay/game/effects/spark_burst.dart';
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
  NovaGame({
    required this.level,
    required this.controller,
    this.snapshot,
    this.reducedMotion = false,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: PhysicsConstants.boardWidth,
           height: PhysicsConstants.boardHeight,
         ),
       );

  final LevelDefinition level;
  final GameSessionController controller;

  /// A snapshot to resume from (pause/kill recovery), if any.
  final GameSnapshot? snapshot;

  /// When true, particle bursts, pops, and the victory bloom are suppressed
  /// (docs/DESIGN_SYSTEM.md §5 reduced-motion rule).
  final bool reducedMotion;

  bool _bloomShown = false;

  /// Minimum drag length (logical units) before a launch is registered.
  static const double _minDrag = 4;

  late final PhysicsEngine _engine;
  late final LevelField _field;
  late final SparkComponent _sparkComponent;
  late final TrajectoryPreview _preview;
  late final HintComponent _hint;
  late final Vector2 _anchor;

  final List<_ShotMemento> _undoStack = [];

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
    _hint = HintComponent(origin: _anchor);
    _sparkComponent = SparkComponent(position: _anchor.clone());

    await world.addAll(_field.visuals);
    await world.add(_preview);
    await world.add(_hint);
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
    clearHint();
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
    // Capture pre-shot state so this shot can be rewound (Undo / Rewind booster).
    _undoStack.add(
      _ShotMemento(
        sparksRemaining: controller.value.sparksRemaining,
        starHits: [for (final star in _field.stars) star.hits],
      ),
    );
    clearHint();
    controller.beginShot();
    _spark = SparkBody(position: _anchor.clone(), velocity: velocity);
    _sparkComponent
      ..position.setFrom(_anchor)
      ..resetTrail();
    _shotActive = true;
    _shotTime = 0;
    _accumulator = 0;
  }

  // ── Undo / Restart / Hint (docs/GAME_DESIGN.md) ──

  /// Whether the last shot can be rewound.
  bool get canUndo =>
      _undoStack.isNotEmpty &&
      !_shotActive &&
      controller.value.status != GameStatus.won;

  /// Rewinds the last shot: restores the spark and re-dims any star it lit.
  void undo() {
    if (!canUndo) return;
    final memento = _undoStack.removeLast();
    for (var i = 0; i < _field.stars.length; i++) {
      final hits = i < memento.starHits.length ? memento.starHits[i] : 0;
      _field.stars[i].hits = hits;
      _field.starComponents[i].setLit(_field.stars[i].isLit);
    }
    final lit = _field.stars.where((s) => s.isLit).length;
    controller.restore(
      controller.value.copyWith(
        sparksRemaining: memento.sparksRemaining,
        starsLit: lit,
        status: GameStatus.aiming,
      ),
    );
    _resetSpark();
  }

  /// Restarts the level in place: clears progress, sparks, and the board.
  void restartLevel() {
    _undoStack.clear();
    _bloomShown = false;
    controller.reset();
    for (var i = 0; i < _field.stars.length; i++) {
      _field.stars[i].hits = 0;
      _field.starComponents[i].setLit(false);
    }
    clearHint();
    _shotActive = false;
    _resetSpark();
  }

  /// Shows a guide line toward the nearest unlit star.
  void showHint() {
    if (controller.value.isOver) return;
    Vector2? nearest;
    var best = double.infinity;
    for (final star in _field.stars) {
      if (star.isLit) continue;
      final d = star.center.distanceTo(_anchor);
      if (d < best) {
        best = d;
        nearest = star.center;
      }
    }
    _hint.target = nearest?.clone();
  }

  /// Hides the hint guide.
  void clearHint() => _hint.target = null;

  void _resetSpark() {
    _spark = SparkBody(position: _anchor.clone());
    _sparkComponent
      ..position.setFrom(_anchor)
      ..resetTrail();
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
        events.starsLit.forEach(_lightStar);
        controller.registerStarsLit(events.starsLit.length);
      }
      if (_shotEnded) break;
    }

    _sparkComponent.position.setFrom(_spark.position);
    _sparkComponent.pushTrail(_spark.position);

    _maybeShowVictoryBloom();
    if (_shotEnded) _finalizeShot();
  }

  /// Lights a star with its celebratory pop and particle burst.
  void _lightStar(int index) {
    _field.starComponents[index]
      ..light()
      ..pop(reducedMotion: reducedMotion);
    if (!reducedMotion) {
      // Fire-and-forget particle effect; it auto-removes when spent.
      // ignore: discarded_futures
      world.add(sparkBurst(_field.stars[index].center, seed: index + 1));
    }
  }

  /// Emits the one victory spectacle when the level is first won.
  void _maybeShowVictoryBloom() {
    if (_bloomShown || controller.value.status != GameStatus.won) return;
    _bloomShown = true;
    if (reducedMotion) return;
    // Fire-and-forget effect; the bloom removes itself when finished.
    // ignore: discarded_futures
    world.add(
      BloomComponent(
        position: Vector2(
          PhysicsConstants.boardWidth / 2,
          PhysicsConstants.boardHeight / 2,
        ),
      ),
    );
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
    _resetSpark();
  }
}

/// Captured state for one shot, enabling Undo / Rewind (docs/GAME_DESIGN.md).
class _ShotMemento {
  _ShotMemento({required this.sparksRemaining, required this.starHits});

  final int sparksRemaining;
  final List<int> starHits;
}
