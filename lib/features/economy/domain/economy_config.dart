import 'package:novaplay/features/economy/domain/booster.dart';

/// Economy balancing constants (docs/MONETIZATION.md §3–4). Server-tunable via
/// Remote Config in a later sprint; centralized here so balancing lives in one
/// place.
abstract final class EconomyConfig {
  // ── Starting balances ──
  static const int startingCoins = 100;
  static const int startingStardust = 0;

  // ── Lives / energy ──
  static const int maxLives = 5;
  static const Duration lifeRegenInterval = Duration(minutes: 20);

  // ── Coin rewards (level completion) ──
  static const int coinsFirstClear = 20;
  static const int coinsReplayClear = 5;
  static const int coinsPerStar = 10;

  // ── XP rewards ──
  static const int xpClear = 10;
  static const int xpPerStar = 5;
  static const int xpSectorFinale = 50;

  // ── Refill / conversion pricing ──
  static const int coinsPerLifeRefill = 200;
  static const int coinsFullLifeRefill = 600;
  static const int stardustToCoinsRate = 100; // 1 stardust = 100 coins

  /// Coin price per booster (docs/MONETIZATION.md §4).
  static const Map<BoosterType, int> boosterCoinPrice = {
    BoosterType.guidedLine: 80,
    BoosterType.slowMo: 120,
    BoosterType.extraSpark: 150,
    BoosterType.bombSpark: 180,
    BoosterType.rewind: 100,
  };

  /// XP needed to advance from [level] to the next: `100 + level × 50`.
  static int xpForNextLevel(int level) => 100 + level * 50;

  /// Coins awarded for completing a level with [stars], honoring first-clear vs
  /// replay and a per-star bonus.
  static int coinsForClear({required int stars, required bool firstClear}) {
    final base = firstClear ? coinsFirstClear : coinsReplayClear;
    return base + stars * coinsPerStar;
  }

  /// XP awarded for completing a level with [stars]; finales grant a bonus.
  static int xpForClear({required int stars, required bool isFinale}) {
    return xpClear + stars * xpPerStar + (isFinale ? xpSectorFinale : 0);
  }
}
