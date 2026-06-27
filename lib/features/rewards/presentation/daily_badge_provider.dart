import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/live/presentation/daily_challenge_provider.dart';
import 'package:novaplay/features/rewards/presentation/missions_providers.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';
import 'package:novaplay/features/rewards/presentation/wheel_chest_providers.dart';

/// True when the Daily tab has something to claim/do — drives the nav badge dot.
final hasUnclaimedDailyProvider = Provider<bool>((ref) {
  final dailyReady = ref.watch(dailyRewardProvider).canClaim;
  final wheelReady = ref.watch(wheelProvider);
  final chestReady = ref.watch(chestProvider);
  final missionReady = ref
      .watch(dailyMissionStatesProvider)
      .any((m) => m.canClaim);
  final challengeReady = !ref.watch(dailyChallengeProvider).doneToday;
  return dailyReady ||
      wheelReady ||
      chestReady ||
      missionReady ||
      challengeReady;
});
