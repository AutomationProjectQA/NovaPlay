import 'package:equatable/equatable.dart';

/// The lifecycle of an in-level play session (docs/GAME_DESIGN.md win/lose).
enum GameStatus {
  /// Waiting for the player to aim & launch the next spark.
  aiming,

  /// A spark is in flight; physics is running.
  shooting,

  /// Play is paused (overlay shown / app backgrounded).
  paused,

  /// All stars lit — the level is cleared.
  won,

  /// Out of sparks with stars still dim.
  lost,
}

/// Immutable snapshot of a play session, surfaced to the HUD and overlays.
class GameState extends Equatable {
  const GameState({
    required this.sparksTotal,
    required this.sparksRemaining,
    required this.starsTotal,
    required this.starsLit,
    required this.parForThreeStars,
    this.status = GameStatus.aiming,
    this.stardust = 0,
  });

  /// The starting state for a level.
  factory GameState.initial({
    required int sparks,
    required int starsTotal,
    required int parForThreeStars,
  }) => GameState(
    sparksTotal: sparks,
    sparksRemaining: sparks,
    starsTotal: starsTotal,
    starsLit: 0,
    parForThreeStars: parForThreeStars,
  );

  final int sparksTotal;
  final int sparksRemaining;
  final int starsTotal;
  final int starsLit;
  final int parForThreeStars;
  final GameStatus status;
  final int stardust;

  int get sparksUsed => sparksTotal - sparksRemaining;
  bool get allStarsLit => starsLit >= starsTotal;
  bool get isOver => status == GameStatus.won || status == GameStatus.lost;

  GameState copyWith({
    int? sparksRemaining,
    int? starsLit,
    GameStatus? status,
    int? stardust,
  }) {
    return GameState(
      sparksTotal: sparksTotal,
      sparksRemaining: sparksRemaining ?? this.sparksRemaining,
      starsTotal: starsTotal,
      starsLit: starsLit ?? this.starsLit,
      parForThreeStars: parForThreeStars,
      status: status ?? this.status,
      stardust: stardust ?? this.stardust,
    );
  }

  @override
  List<Object?> get props => [
    sparksTotal,
    sparksRemaining,
    starsTotal,
    starsLit,
    parForThreeStars,
    status,
    stardust,
  ];
}
