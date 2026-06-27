import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/economy/data/economy_repository.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/domain/achievement.dart';
import 'package:novaplay/features/rewards/domain/daily_reward.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/domain/reward_roller.dart';
import 'package:novaplay/features/rewards/presentation/missions_providers.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

ProviderContainer _rewardsContainer() {
  final container = ProviderContainer(
    overrides: [
      rewardsRepositoryProvider.overrideWithValue(RewardsRepository(null)),
      economyRepositoryProvider.overrideWithValue(EconomyRepository(null)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('evaluateDaily', () {
    test('first ever claim is available on ladder day 1', () {
      final s = evaluateDaily(lastClaimDay: 0, streak: 0, today: 100);
      expect(s.canClaim, isTrue);
      expect(s.claimDay, 1);
    });
    test('consecutive day advances the streak', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 1, today: 101);
      expect(s.canClaim, isTrue);
      expect(s.claimDay, 2);
    });
    test('a missed day resets to day 1', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 4, today: 103);
      expect(s.claimDay, 1);
    });
    test('already claimed today cannot claim again', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 3, today: 100);
      expect(s.canClaim, isFalse);
    });
    test('ladder wraps after 7 days', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 7, today: 101);
      expect(s.claimDay, 1); // day 8 wraps to ladder index 0
    });
  });

  group('rollReward', () {
    test('all weight on one entry always returns it', () {
      final entries = [
        const WeightedReward(Reward(coins: 10), 0),
        const WeightedReward(Reward(coins: 99), 1),
      ];
      expect(rollReward(entries, Random(1)).coins, 99);
    });
    test('empty/zero-weight yields an empty reward', () {
      expect(rollReward(const [], Random(1)).isEmpty, isTrue);
    });
  });

  group('DailyRewardNotifier', () {
    test('claiming credits coins and blocks a second claim', () {
      final container = ProviderContainer(
        overrides: [
          rewardsRepositoryProvider.overrideWithValue(RewardsRepository(null)),
          economyRepositoryProvider.overrideWithValue(EconomyRepository(null)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(dailyRewardProvider.notifier);
      expect(container.read(dailyRewardProvider).canClaim, isTrue);

      final reward = notifier.claim();
      expect(reward, isNotNull);
      expect(reward!.coins, kDailyLadder.first.coins);
      expect(container.read(walletProvider).coins, greaterThan(0));

      // Second claim today is rejected.
      expect(notifier.claim(), isNull);
    });
  });

  group('achievementMetrics', () {
    test('derives cleared / stars / three-star counts', () {
      final m = achievementMetrics({1: 3, 2: 1, 3: 0, 4: 3});
      expect(m[AchievementMetric.levelsCleared], 3);
      expect(m[AchievementMetric.totalStars], 7);
      expect(m[AchievementMetric.threeStarLevels], 2);
    });
  });

  group('MissionsNotifier', () {
    test('records clears and claims a completed mission once', () {
      final container = _rewardsContainer();
      final missions = container.read(missionsProvider.notifier)
        ..recordLevelCleared(2)
        ..recordLevelCleared(2)
        ..recordLevelCleared(2);

      final clear3 = container
          .read(dailyMissionStatesProvider)
          .firstWhere((s) => s.mission.id == 'clear3');
      expect(clear3.progress, 3);
      expect(clear3.canClaim, isTrue);

      expect(missions.claim('clear3'), isTrue);
      expect(missions.claim('clear3'), isFalse); // already claimed
    });
  });
}
