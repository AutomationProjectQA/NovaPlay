import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/domain/reward_roller.dart';
import 'package:novaplay/features/rewards/domain/reward_tables.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

/// Whether today's free Lucky Wheel spin is still available.
final wheelProvider = NotifierProvider<WheelNotifier, bool>(WheelNotifier.new);

class WheelNotifier extends Notifier<bool> {
  final Random _random = Random();
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);

  @override
  bool build() => _repo.wheelLastDay != todayEpochDay();

  /// Spins the wheel. The free daily spin consumes the day; an ad spin
  /// ([viaAd]) does not. Returns the prize, or null if no spin is available.
  Reward? spin({bool viaAd = false}) {
    if (!viaAd && !state) return null;
    final reward = rollReward(kWheelRewards, _random);
    applyReward(ref, reward);
    if (!viaAd) {
      unawaited(_repo.setWheelLastDay(todayEpochDay()));
      state = false;
    }
    return reward;
  }
}

/// Whether today's free Mystery Chest is still available.
final chestProvider = NotifierProvider<ChestNotifier, bool>(ChestNotifier.new);

class ChestNotifier extends Notifier<bool> {
  final Random _random = Random();
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);

  @override
  bool build() => _repo.chestLastDay != todayEpochDay();

  /// Opens the daily chest. Returns the prize, or null if already opened today.
  Reward? open() {
    if (!state) return null;
    final reward = rollReward(kChestRewards, _random);
    applyReward(ref, reward);
    unawaited(_repo.setChestLastDay(todayEpochDay()));
    state = false;
    return reward;
  }
}
