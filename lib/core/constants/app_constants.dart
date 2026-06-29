/// App-wide constant keys: Hive box names, Remote Config keys, ad placements.
/// Centralized so strings are never duplicated across the codebase.
library;

/// Hive box names (docs/ARCHITECTURE.md §9).
abstract final class HiveBoxes {
  static const String progress = 'progress';
  static const String settings = 'settings';
  static const String economy = 'economy';
  static const String levelCache = 'level_cache';

  /// In-flight level snapshots for pause/resume (docs/ARCHITECTURE.md §8.10).
  static const String session = 'session';

  /// Daily rewards, streaks, missions, achievements, chests (Sprint 14).
  static const String rewards = 'rewards';
}

/// Remote Config keys (server-tunable; docs/MONETIZATION.md & ARCHITECTURE.md §10).
abstract final class RcKeys {
  static const String interstitialEveryNLevels = 'interstitial_every_n_levels';
  static const String livesRegenMinutes = 'lives_regen_minutes';
  static const String maxLives = 'max_lives';
  static const String coinsPerLevel = 'coins_per_level';
  static const String featureLeaderboards = 'feature_leaderboards_enabled';

  /// A/B test hooks (docs/MONETIZATION.md A/B testing).
  static const String featureRewardedContinue = 'feature_rewarded_continue';
  static const String adsExperimentVariant = 'ads_experiment_variant';

  /// LiveOps kill switch / forced update (docs/LIVEOPS.md). Builds below
  /// [minSupportedBuild] are blocked; [latestBuild] drives an optional nudge.
  static const String minSupportedBuild = 'min_supported_build';
  static const String latestBuild = 'latest_build';

  /// Per-experiment server override: `exp_<experimentKey>` → a variant id,
  /// `control`, or `auto` (deterministic assignment). See docs/LIVEOPS.md.
  static String experimentOverride(String experimentKey) =>
      'exp_$experimentKey';
}

/// The running build number. Keep in sync with pubspec `version: X.Y.Z+build`
/// (the `+build` part); wire to `package_info_plus` to read it at runtime later.
/// Used by the forced-update gate (docs/LIVEOPS.md).
abstract final class AppBuild {
  static const int number = 1;
}

/// Outbound links and contact info shown in Settings / store flows
/// (docs/legal/, docs/RELEASE_PLAN.md). Replace the hosted URLs with the final
/// published locations before store submission.
abstract final class AppLinks {
  static const String privacyPolicy = 'https://novaplay.app/privacy';
  static const String terms = 'https://novaplay.app/terms';
  static const String support = 'mailto:support@novaplay.app';

  /// Store listing IDs used to deep-link the "Rate us" / store flows.
  static const String androidPackageId = 'com.novaplay.novaplay';
  static const String appStoreId = '000000000'; // TODO: real Apple app ID
}

/// AdMob placement identifiers (docs/MONETIZATION.md ad strategy).
enum AdPlacement {
  rewardedExtraSpark,
  rewardedDoubleCoins,
  rewardedLifeRefill,
  rewardedFreeBooster,
  interstitialBetweenLevels,
}
