import 'package:flutter/foundation.dart';
import 'package:novaplay/game/session/game_result.dart';
import 'package:novaplay/game/session/game_state.dart';

/// The single bridge between the Flame world and the app (docs/ARCHITECTURE.md
/// §8.2). Owns the authoritative [GameState] as a [ValueListenable] the HUD and
/// overlays bind to, and applies the win/lose rules. Pure Dart — unit-testable
/// without Flame.
class GameSessionController {
  GameSessionController({
    required this.levelId,
    required GameState initial,
    this.onComplete,
  }) : _state = ValueNotifier(initial);

  final int levelId;
  final ValueNotifier<GameState> _state;

  /// Called once when the level is won or lost.
  final void Function(GameResult result)? onComplete;

  GameStatus? _statusBeforePause;

  /// The live game state for the UI to listen to.
  ValueListenable<GameState> get state => _state;
  GameState get value => _state.value;

  /// Consumes a spark and starts the shot. No-op unless currently aiming.
  void beginShot() {
    if (value.status != GameStatus.aiming || value.sparksRemaining <= 0) return;
    _state.value = value.copyWith(
      status: GameStatus.shooting,
      sparksRemaining: value.sparksRemaining - 1,
    );
  }

  /// Records [count] newly-lit stars; wins immediately if that lights them all.
  void registerStarsLit(int count) {
    if (count <= 0 || value.isOver) return;
    final lit = (value.starsLit + count).clamp(0, value.starsTotal);
    _state.value = value.copyWith(starsLit: lit);
    if (value.allStarsLit) _finish(won: true);
  }

  /// Adds collected stardust (bonus pickups).
  void addStardust(int amount) {
    if (amount <= 0 || value.isOver) return;
    _state.value = value.copyWith(stardust: value.stardust + amount);
  }

  /// Called when the in-flight spark has settled or been consumed. Resolves a
  /// loss if no sparks remain, otherwise returns to aiming for the next shot.
  void endShot() {
    if (value.isOver || value.status == GameStatus.paused) return;
    if (value.sparksRemaining <= 0) {
      _finish(won: false);
    } else {
      _state.value = value.copyWith(status: GameStatus.aiming);
    }
  }

  void pause() {
    if (value.isOver || value.status == GameStatus.paused) return;
    _statusBeforePause = value.status;
    _state.value = value.copyWith(status: GameStatus.paused);
  }

  void resume() {
    if (value.status != GameStatus.paused) return;
    _state.value = value.copyWith(
      status: _statusBeforePause ?? GameStatus.aiming,
    );
    _statusBeforePause = null;
  }

  /// The result for the current state (used for overlays / persistence).
  GameResult buildResult() {
    final won = value.allStarsLit;
    return GameResult(
      levelId: levelId,
      won: won,
      stars: won
          ? starsForResult(
              sparksUsed: value.sparksUsed,
              parForThreeStars: value.parForThreeStars,
              sparksTotal: value.sparksTotal,
            )
          : 0,
      sparksUsed: value.sparksUsed,
      stardust: value.stardust,
    );
  }

  void _finish({required bool won}) {
    _state.value = value.copyWith(
      status: won ? GameStatus.won : GameStatus.lost,
    );
    onComplete?.call(buildResult());
  }

  /// Restores a previously persisted in-level snapshot (docs/ARCHITECTURE.md
  /// §8.10).
  // ignore: use_setters_to_change_properties
  void restore(GameState snapshot) => _state.value = snapshot;

  void dispose() => _state.dispose();
}
