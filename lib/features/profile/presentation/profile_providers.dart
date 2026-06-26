import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/profile/domain/player_profile.dart';

/// The player's profile summary. Stubbed for Sprint 7; derived from real saved
/// progress (XP, stars, streaks) in Sprints 10/14.
final playerProfileProvider = Provider<PlayerProfile>((ref) {
  return const PlayerProfile(
    displayName: 'Stardrifter',
    level: 7,
    xpProgress: 0.6,
    totalStars: 124,
    starsThisSector: 41,
    starsSectorTotal: 60,
    bestStreak: 9,
  );
});
