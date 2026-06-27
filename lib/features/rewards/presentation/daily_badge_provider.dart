import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/rewards/presentation/missions_providers.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';
import 'package:novaplay/features/rewards/presentation/wheel_chest_providers.dart';

/// True when the Daily tab has something to claim — drives the nav badge dot.
final hasUnclaimedDailyProvider = Provider<bool>((ref) {
  final dailyReady = ref.watch(dailyRewardProvider).canClaim;
  final wheelReady = ref.watch(wheelProvider);
  final chestReady = ref.watch(chestProvider);
  final missionReady = ref
      .watch(dailyMissionStatesProvider)
      .any((m) => m.canClaim);
  return dailyReady || wheelReady || chestReady || missionReady;
});
