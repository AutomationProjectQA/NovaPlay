import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/economy/data/economy_repository.dart';
import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/domain/lives_math.dart';
import 'package:novaplay/features/economy/domain/player_xp.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      economyRepositoryProvider.overrideWithValue(EconomyRepository(null)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('EconomyConfig', () {
    test('coin reward = base + per-star, first clear vs replay', () {
      expect(EconomyConfig.coinsForClear(stars: 3, firstClear: true), 50);
      expect(EconomyConfig.coinsForClear(stars: 3, firstClear: false), 35);
    });
    test('xp reward includes finale bonus', () {
      expect(EconomyConfig.xpForClear(stars: 2, isFinale: false), 20);
      expect(EconomyConfig.xpForClear(stars: 2, isFinale: true), 70);
    });
  });

  group('PlayerXp curve', () {
    test('level 1 until 150 xp, then level 2', () {
      expect(PlayerXp.fromTotal(0).level, 1);
      expect(PlayerXp.fromTotal(149).level, 1);
      expect(PlayerXp.fromTotal(150).level, 2); // 100 + 1*50
    });
  });

  group('regenerateLives', () {
    const interval = EconomyConfig.lifeRegenInterval;
    test('full lives stay full', () {
      final r = regenerateLives(storedCount: 5, lastRegenMs: 0, nowMs: 0);
      expect(r.lives.current, 5);
      expect(r.lives.isFull, isTrue);
    });
    test('one life regenerates after the interval', () {
      final now = interval.inMilliseconds + 5;
      final r = regenerateLives(storedCount: 2, lastRegenMs: 0, nowMs: now);
      expect(r.lives.current, 3);
      expect(r.lives.nextRegen, isNotNull);
    });
    test('regeneration caps at max', () {
      final now = interval.inMilliseconds * 10;
      final r = regenerateLives(storedCount: 1, lastRegenMs: 0, nowMs: now);
      expect(r.lives.current, EconomyConfig.maxLives);
    });
  });

  group('WalletNotifier', () {
    test('earn and spend coins; spend fails when unaffordable', () {
      final c = _container();
      final wallet = c.read(walletProvider.notifier)..earnCoins(50);
      expect(c.read(walletProvider).coins, EconomyConfig.startingCoins + 50);
      expect(wallet.spendCoins(40), isTrue);
      expect(wallet.spendCoins(100000), isFalse);
    });

    test('stardust converts to coins at the fixed rate', () {
      final c = _container();
      final wallet = c.read(walletProvider.notifier)..earnStardust(2);
      expect(wallet.convertStardust(2), isTrue);
      expect(
        c.read(walletProvider).coins,
        EconomyConfig.startingCoins + 2 * EconomyConfig.stardustToCoinsRate,
      );
      expect(c.read(walletProvider).stardust, 0);
    });
  });

  group('BoostersNotifier', () {
    test('buy spends coins and grants one; use decrements', () {
      final c = _container();
      final boosters = c.read(boostersProvider.notifier);
      expect(boosters.buy(BoosterType.rewind), isTrue);
      expect(boosters.count(BoosterType.rewind), 1);
      expect(boosters.use(BoosterType.rewind), isTrue);
      expect(boosters.count(BoosterType.rewind), 0);
      expect(boosters.use(BoosterType.rewind), isFalse);
    });
  });
}
