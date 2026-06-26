/// App-wide constant keys: Hive box names, Remote Config keys, ad placements.
/// Centralized so strings are never duplicated across the codebase.
library;

/// Hive box names (docs/ARCHITECTURE.md §9).
abstract final class HiveBoxes {
  static const String progress = 'progress';
  static const String settings = 'settings';
  static const String economy = 'economy';
  static const String levelCache = 'level_cache';
}

/// Remote Config keys (server-tunable; docs/MONETIZATION.md & ARCHITECTURE.md §10).
abstract final class RcKeys {
  static const String interstitialEveryNLevels = 'interstitial_every_n_levels';
  static const String livesRegenMinutes = 'lives_regen_minutes';
  static const String maxLives = 'max_lives';
  static const String coinsPerLevel = 'coins_per_level';
  static const String featureLeaderboards = 'feature_leaderboards_enabled';
}

/// AdMob placement identifiers (docs/MONETIZATION.md ad strategy).
enum AdPlacement {
  rewardedExtraSpark,
  rewardedDoubleCoins,
  rewardedLifeRefill,
  rewardedFreeBooster,
  interstitialBetweenLevels,
}
