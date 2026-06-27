import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/profile/domain/player_profile.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// The player's profile summary. Stars come from saved progress; player level +
/// XP from the economy's XP system. Best streak lands with missions (Sprint 15).
final playerProfileProvider = Provider<PlayerProfile>((ref) {
  final totalStars = ref.watch(totalStarsProvider);
  final highest = ref.watch(highestUnlockedLevelProvider);
  final xp = ref.watch(playerXpProvider);
  final sectors = ref.watch(sectorsProvider);
  final current = sectors.firstWhere(
    (s) => highest >= s.firstLevel && highest <= s.lastLevel,
    orElse: () => sectors.first,
  );

  return PlayerProfile(
    displayName: 'Stardrifter',
    level: xp.level,
    xpProgress: xp.progress,
    totalStars: totalStars,
    starsThisSector: current.starsEarned,
    starsSectorTotal: current.starsTotal,
    bestStreak: 0,
  );
});
