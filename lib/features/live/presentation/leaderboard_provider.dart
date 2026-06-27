import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/leaderboard_service.dart';
import 'package:novaplay/features/profile/presentation/profile_providers.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// The ranked leaderboard, with the player scored by total stars.
final leaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  final score = ref.watch(totalStarsProvider);
  final name = ref.watch(playerProfileProvider).displayName;
  return getIt<LeaderboardService>().board(
    playerScore: score,
    playerName: name,
  );
});
