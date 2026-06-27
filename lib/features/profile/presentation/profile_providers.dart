import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/profile/domain/player_profile.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// The player's profile summary. Star totals are derived from saved progress;
/// name/level/XP/streak remain stubbed until Sprint 14 wires the economy.
final playerProfileProvider = Provider<PlayerProfile>((ref) {
  final totalStars = ref.watch(totalStarsProvider);
  final highest = ref.watch(highestUnlockedLevelProvider);
  final sectors = ref.watch(sectorsProvider);
  final current = sectors.firstWhere(
    (s) => highest >= s.firstLevel && highest <= s.lastLevel,
    orElse: () => sectors.first,
  );

  return PlayerProfile(
    displayName: 'Stardrifter',
    level: 1 + totalStars ~/ 9,
    xpProgress: (totalStars % 9) / 9,
    totalStars: totalStars,
    starsThisSector: current.starsEarned,
    starsSectorTotal: current.starsTotal,
    bestStreak: 0,
  );
});
