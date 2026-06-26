import 'package:equatable/equatable.dart';

/// The player's progression summary shown on the Profile screen
/// (docs/UI_GUIDELINES.md §3.9). Real values are derived from saved progress in
/// later sprints.
class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.displayName,
    required this.level,
    required this.xpProgress,
    required this.totalStars,
    required this.starsThisSector,
    required this.starsSectorTotal,
    required this.bestStreak,
  });

  final String displayName;
  final int level;

  /// Progress toward the next level, 0–1.
  final double xpProgress;
  final int totalStars;
  final int starsThisSector;
  final int starsSectorTotal;
  final int bestStreak;

  @override
  List<Object?> get props => [
    displayName,
    level,
    xpProgress,
    totalStars,
    starsThisSector,
    starsSectorTotal,
    bestStreak,
  ];
}
