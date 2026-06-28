// Sprint 19 (QA) — boundary & edge-case regression suite. These lock down the
// corners of the pure logic that the per-feature tests don't exercise: clock
// going backwards, streak resets and ladder wrap, reward-weight bounds, ad-cap
// gates, currency floors, and physics anti-tunnelling from awkward angles.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/ad_frequency.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/domain/lives_math.dart';
import 'package:novaplay/features/economy/domain/player_xp.dart';
import 'package:novaplay/features/economy/domain/wallet.dart';
import 'package:novaplay/features/live/domain/daily_challenge.dart';
import 'package:novaplay/features/live/domain/game_event.dart';
import 'package:novaplay/features/progress/domain/level_progress.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/rewards/domain/daily_reward.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/domain/reward_roller.dart';
import 'package:novaplay/game/physics/colliders.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/physics/physics_engine.dart';
import 'package:novaplay/game/physics/spark_body.dart';
import 'package:vector_math/vector_math.dart';

const _min = 60 * 1000;
const _intervalMs = 20 * _min; // life regen interval

void main() {
  group('economy boundaries', () {
    test('canAfford is inclusive at the exact price', () {
      const wallet = Wallet(coins: 200);
      expect(wallet.canAfford(200), isTrue);
      expect(wallet.canAfford(201), isFalse);
      expect(wallet.canAfford(0), isTrue);
    });

    test('coin reward: first clear vs replay, plus per-star bonus', () {
      expect(EconomyConfig.coinsForClear(stars: 0, firstClear: true), 20);
      expect(EconomyConfig.coinsForClear(stars: 3, firstClear: true), 50);
      expect(EconomyConfig.coinsForClear(stars: 3, firstClear: false), 35);
    });

    test('xp reward: finale bonus only on finales', () {
      expect(EconomyConfig.xpForClear(stars: 0, isFinale: false), 10);
      expect(EconomyConfig.xpForClear(stars: 3, isFinale: false), 25);
      expect(EconomyConfig.xpForClear(stars: 3, isFinale: true), 75);
    });

    test('XP level derivation is exact at level boundaries', () {
      // XP_to_next(1) = 150, XP_to_next(2) = 200.
      final atZero = PlayerXp.fromTotal(0);
      expect(atZero.level, 1);
      expect(atZero.xpForNextLevel, 150);
      expect(atZero.progress, 0);

      final justBelow = PlayerXp.fromTotal(149);
      expect(justBelow.level, 1);
      expect(justBelow.xpIntoLevel, 149);

      final exactlyUp = PlayerXp.fromTotal(150);
      expect(exactlyUp.level, 2);
      expect(exactlyUp.xpIntoLevel, 0);

      final intoTwo = PlayerXp.fromTotal(150 + 199);
      expect(intoTwo.level, 2);
      expect(intoTwo.xpIntoLevel, 199);
    });
  });

  group('lives regeneration edge cases', () {
    test('a backwards clock never grants lives', () {
      final r = regenerateLives(
        storedCount: 2,
        lastRegenMs: 10 * _intervalMs, // anchor in the "future"
        nowMs: 1 * _intervalMs,
      );
      expect(r.lives.current, 2);
      expect(r.lives.nextRegen, isNotNull);
      expect(r.lives.nextRegen!.inMilliseconds, lessThanOrEqualTo(_intervalMs));
    });

    test('a huge gap caps at max and clears the countdown', () {
      final r = regenerateLives(
        storedCount: 0,
        lastRegenMs: 0,
        nowMs: 365 * 24 * 60 * _min, // a year later
      );
      expect(r.lives.current, EconomyConfig.maxLives);
      expect(r.lives.isFull, isTrue);
      expect(r.lives.nextRegen, isNull);
    });

    test('already full: no countdown, anchor reset to now', () {
      final r = regenerateLives(
        storedCount: 5,
        lastRegenMs: 0,
        nowMs: 12345,
      );
      expect(r.lives.current, 5);
      expect(r.lives.nextRegen, isNull);
      expect(r.lastRegenMs, 12345);
    });

    test('partial interval carries the remainder forward', () {
      // 1.5 intervals elapsed from empty → +1 life, 0.5 interval remaining.
      final r = regenerateLives(
        storedCount: 0,
        lastRegenMs: 0,
        nowMs: _intervalMs + _intervalMs ~/ 2,
      );
      expect(r.lives.current, 1);
      expect(r.lives.nextRegen!.inMilliseconds, _intervalMs ~/ 2);
    });
  });

  group('daily reward streak edge cases', () {
    test('first claim ever starts the streak at day 1', () {
      final s = evaluateDaily(lastClaimDay: 0, streak: 0, today: 19_000);
      expect(s.canClaim, isTrue);
      expect(s.claimDay, 1);
      expect(s.reward, kDailyLadder.first);
    });

    test('a consecutive day advances the ladder', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 3, today: 101);
      expect(s.canClaim, isTrue);
      expect(s.claimDay, 4);
    });

    test('a missed day resets to day 1', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 5, today: 103);
      expect(s.canClaim, isTrue);
      expect(s.claimDay, 1);
    });

    test('already claimed today cannot claim again', () {
      final s = evaluateDaily(lastClaimDay: 100, streak: 4, today: 100);
      expect(s.canClaim, isFalse);
    });

    test('the ladder wraps after 7 days', () {
      // Credited streak 7, claiming a consecutive day → streak 8 → wraps to 1.
      final s = evaluateDaily(lastClaimDay: 100, streak: 7, today: 101);
      expect(s.claimDay, 1);
    });
  });

  group('ad frequency cap', () {
    test('no ads before the minimum level, regardless of cadence', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 3,
          levelsSinceLastAd: 99,
          everyN: 1,
        ),
        isFalse,
      );
    });

    test('a non-positive cadence disables interstitials', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 50,
          levelsSinceLastAd: 50,
          everyN: 0,
        ),
        isFalse,
      );
    });

    test('fires exactly when the cadence is reached', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 4,
          levelsSinceLastAd: 2,
          everyN: 3,
        ),
        isFalse,
      );
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 4,
          levelsSinceLastAd: 3,
          everyN: 3,
        ),
        isTrue,
      );
    });
  });

  group('reward roller', () {
    final entries = [
      const WeightedReward(Reward(coins: 10), 1),
      const WeightedReward(Reward(coins: 50), 3),
      const WeightedReward(Reward(stardust: 1), 6),
    ];

    test('is deterministic for a fixed seed', () {
      final a = rollReward(entries, Random(42));
      final b = rollReward(entries, Random(42));
      expect(a, b);
    });

    test('only ever returns one of the provided rewards', () {
      final rng = Random(7);
      for (var i = 0; i < 200; i++) {
        expect(
          entries.map((e) => e.reward),
          contains(rollReward(entries, rng)),
        );
      }
    });

    test('zero total weight yields an empty reward', () {
      final r = rollReward(
        [const WeightedReward(Reward(coins: 99), 0)],
        Random(1),
      );
      expect(r.isEmpty, isTrue);
    });
  });

  group('reward formatting', () {
    test('empty reward summarises as "Nothing"', () {
      expect(const Reward().summary, 'Nothing');
      expect(const Reward().isEmpty, isTrue);
    });

    test('multi-part summary joins with a middle dot', () {
      const r = Reward(coins: 120, stardust: 5);
      expect(r.summary, '120 coins · 5 stardust');
      expect(r.isEmpty, isFalse);
    });
  });

  group('progress & live content boundaries', () {
    test('LevelProgress.isCleared flips at the first star', () {
      expect(const LevelProgress(levelId: 1, stars: 0).isCleared, isFalse);
      expect(const LevelProgress(levelId: 1, stars: 1).isCleared, isTrue);
    });

    test('daily challenge stays in range and wraps the catalog', () {
      expect(challengeLevelId(0), 1);
      expect(challengeLevelId(kTotalLevels - 1), kTotalLevels);
      expect(challengeLevelId(kTotalLevels), 1); // wraps
      for (var day = 0; day < kTotalLevels * 3; day++) {
        expect(challengeLevelId(day), inInclusiveRange(1, kTotalLevels));
      }
    });

    test('weekends run Double Coins; weekdays do not', () {
      expect(
        activeEvent(today: 10, weekday: DateTime.saturday).coinMultiplier,
        2,
      );
      expect(activeEvent(today: 10, weekday: DateTime.sunday).hasBonus, isTrue);
      expect(
        activeEvent(today: 10, weekday: DateTime.wednesday).hasBonus,
        isFalse,
      );
    });
  });

  group('physics anti-tunnelling & preview safety', () {
    const dt = PhysicsConstants.fixedDt;

    test('a fast diagonal shot never escapes the board', () {
      final engine = PhysicsEngine(segments: boardBoundaries());
      final spark = SparkBody(
        position: Vector2(50, 80),
        velocity: Vector2(4000, -4000),
      );
      for (var i = 0; i < 600; i++) {
        engine.step(spark, dt);
        expect(
          spark.position.x,
          inInclusiveRange(0, PhysicsConstants.boardWidth),
        );
        expect(
          spark.position.y,
          inInclusiveRange(0, PhysicsConstants.boardHeight),
        );
      }
    });

    test('previewPath is deterministic and read-only', () {
      final engine = PhysicsEngine(segments: boardBoundaries());
      SparkBody start() =>
          SparkBody(position: Vector2(50, 80), velocity: Vector2(30, -30));
      final a = engine.previewPath(start());
      final b = engine.previewPath(start());
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[i]);
      }
    });
  });
}
