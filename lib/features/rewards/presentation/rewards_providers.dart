import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/domain/daily_reward.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';

/// Provides retention persistence.
final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository(rewardsBox());
});

/// Today's epoch-day, from the wall clock.
int todayEpochDay() => epochDay(DateTime.now().millisecondsSinceEpoch);

/// Credits a [Reward] to the economy (coins, stardust, boosters). Shared by all
/// reward sources (daily, wheel, chest, missions, achievements).
void applyReward(Ref ref, Reward reward) {
  final wallet = ref.read(walletProvider.notifier);
  if (reward.coins > 0) wallet.earnCoins(reward.coins);
  if (reward.stardust > 0) wallet.earnStardust(reward.stardust);
  final boosters = ref.read(boostersProvider.notifier);
  reward.boosters.forEach(boosters.grant);
}

// ── Daily reward + streak ──

final dailyRewardProvider = NotifierProvider<DailyRewardNotifier, DailyStatus>(
  DailyRewardNotifier.new,
);

class DailyRewardNotifier extends Notifier<DailyStatus> {
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);
  int get _today => todayEpochDay();

  @override
  DailyStatus build() => evaluateDaily(
    lastClaimDay: _repo.dailyLastClaimDay,
    streak: _repo.dailyStreak,
    today: _today,
  );

  /// Claims today's reward, returning it (or null if already claimed).
  Reward? claim() {
    if (!state.canClaim) return null;

    final today = _today;
    final last = _repo.dailyLastClaimDay;
    final streak = _repo.dailyStreak;
    final consecutive = last == today - 1;
    final newStreak = (last != 0 && consecutive) ? streak + 1 : 1;
    final reward = state.reward;

    applyReward(ref, reward);
    unawaited(_repo.setDaily(newStreak, today));
    state = evaluateDaily(
      lastClaimDay: today,
      streak: newStreak,
      today: today,
    );
    return reward;
  }
}
