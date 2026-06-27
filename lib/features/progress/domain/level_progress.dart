import 'package:equatable/equatable.dart';

/// The player's best result on a single level (docs/LEVEL_DESIGN.md progress).
class LevelProgress extends Equatable {
  const LevelProgress({required this.levelId, required this.stars});

  final int levelId;

  /// Best stars earned, 0–3. 0 means not yet cleared.
  final int stars;

  bool get isCleared => stars > 0;

  @override
  List<Object?> get props => [levelId, stars];
}
