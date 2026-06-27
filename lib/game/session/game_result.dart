import 'package:equatable/equatable.dart';

/// The outcome of a finished level, handed to the app layer to persist progress,
/// award coins/XP, and drive the Win/Lose overlay (docs/GAME_DESIGN.md).
class GameResult extends Equatable {
  const GameResult({
    required this.levelId,
    required this.won,
    required this.stars,
    required this.sparksUsed,
    required this.stardust,
  });

  final int levelId;
  final bool won;

  /// 0–3 stars (0 only when lost).
  final int stars;
  final int sparksUsed;
  final int stardust;

  @override
  List<Object?> get props => [levelId, won, stars, sparksUsed, stardust];
}

/// The hybrid star-rating scheme (docs/GAME_DESIGN.md): 3 stars at or under par,
/// 2 stars within the upper-mid band, otherwise 1 star for any win.
int starsForResult({
  required int sparksUsed,
  required int parForThreeStars,
  required int sparksTotal,
}) {
  if (sparksUsed <= parForThreeStars) return 3;
  final twoStarLimit =
      parForThreeStars + ((sparksTotal - parForThreeStars + 1) ~/ 2);
  if (sparksUsed <= twoStarLimit) return 2;
  return 1;
}
