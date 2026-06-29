// Analytics logging is intentionally fire-and-forget (never awaited at call sites).
// ignore_for_file: discarded_futures
import 'package:novaplay/core/services/analytics_service.dart';

/// Canonical analytics event + parameter names (docs/ANALYTICS.md §3). snake_case,
/// ≤ 40 chars, no reserved prefixes — the single source of truth for the taxonomy.
abstract final class AnalyticsEvent {
  static const String appOpen = 'app_open';
  static const String tutorialComplete = 'tutorial_complete';
  static const String levelStart = 'level_start';
  static const String levelComplete = 'level_complete';
  static const String levelFail = 'level_fail';
  static const String restart = 'restart';
  static const String boosterUsed = 'booster_used';
  static const String hintUsed = 'hint_used';
  static const String currencyEarned = 'currency_earned';
  static const String currencySpent = 'currency_spent';
  static const String lifeRefill = 'life_refill';
  static const String adShown = 'ad_shown';
  static const String adRewarded = 'ad_rewarded';
  static const String adFailed = 'ad_failed';
  static const String dailyRewardClaimed = 'daily_reward_claimed';
  static const String dailyChallengePlayed = 'daily_challenge_played';
  static const String settingsChanged = 'settings_changed';
  static const String errorNonfatal = 'error_nonfatal';
  static const String experimentExposure = 'experiment_exposure';
  static const String appUpdatePrompt = 'app_update_prompt';
}

/// Shared parameter keys.
abstract final class AnalyticsParam {
  static const String levelId = 'level_id';
  static const String sectorId = 'sector_id';
  static const String stars = 'stars';
  static const String sparksUsed = 'sparks_used';
  static const String starsLit = 'stars_lit';
  static const String currency = 'currency';
  static const String amount = 'amount';
  static const String source = 'source';
  static const String sink = 'sink';
  static const String placement = 'placement';
  static const String adFormat = 'ad_format';
  static const String method = 'method';
  static const String streakDay = 'streak_day';
  static const String setting = 'setting';
  static const String value = 'value';
  static const String result = 'result';
  static const String errorDomain = 'error_domain';
  static const String context = 'context';
  static const String experiment = 'experiment';
  static const String variant = 'variant';
  static const String status = 'status';
}

/// Typed, taxonomy-safe wrappers over [AnalyticsService.logEvent]. Call these
/// instead of raw string events so the catalog stays consistent.
extension NovaAnalytics on AnalyticsService {
  void logAppOpen() => logEvent(AnalyticsEvent.appOpen);

  void logLevelStart({required int levelId, required int sectorId}) {
    logEvent(
      AnalyticsEvent.levelStart,
      parameters: {
        AnalyticsParam.levelId: levelId,
        AnalyticsParam.sectorId: sectorId,
      },
    );
  }

  void logLevelComplete({
    required int levelId,
    required int sectorId,
    required int stars,
    required int sparksUsed,
  }) {
    logEvent(
      AnalyticsEvent.levelComplete,
      parameters: {
        AnalyticsParam.levelId: levelId,
        AnalyticsParam.sectorId: sectorId,
        AnalyticsParam.stars: stars,
        AnalyticsParam.sparksUsed: sparksUsed,
      },
    );
  }

  void logLevelFail({
    required int levelId,
    required int sectorId,
    required int starsLit,
  }) {
    logEvent(
      AnalyticsEvent.levelFail,
      parameters: {
        AnalyticsParam.levelId: levelId,
        AnalyticsParam.sectorId: sectorId,
        AnalyticsParam.starsLit: starsLit,
      },
    );
  }

  void logCurrencyEarned({
    required String currency,
    required int amount,
    required String source,
  }) {
    logEvent(
      AnalyticsEvent.currencyEarned,
      parameters: {
        AnalyticsParam.currency: currency,
        AnalyticsParam.amount: amount,
        AnalyticsParam.source: source,
      },
    );
  }

  void logAdRewarded({required String placement}) {
    logEvent(
      AnalyticsEvent.adRewarded,
      parameters: {AnalyticsParam.placement: placement},
    );
  }

  void logDailyRewardClaimed({required int streakDay}) {
    logEvent(
      AnalyticsEvent.dailyRewardClaimed,
      parameters: {AnalyticsParam.streakDay: streakDay},
    );
  }

  void logDailyChallengePlayed({required int levelId, required String result}) {
    logEvent(
      AnalyticsEvent.dailyChallengePlayed,
      parameters: {
        AnalyticsParam.levelId: levelId,
        AnalyticsParam.result: result,
      },
    );
  }

  void logSettingsChanged({required String setting, required Object value}) {
    logEvent(
      AnalyticsEvent.settingsChanged,
      parameters: {
        AnalyticsParam.setting: setting,
        AnalyticsParam.value: value,
      },
    );
  }

  void logErrorNonfatal({required String domain, required String context}) {
    logEvent(
      AnalyticsEvent.errorNonfatal,
      parameters: {
        AnalyticsParam.errorDomain: domain,
        AnalyticsParam.context: context,
      },
    );
  }

  /// Logs that a player was exposed to [variant] of an A/B [experiment]. Call
  /// when the variant first affects behaviour (docs/LIVEOPS.md).
  void logExperimentExposure({
    required String experiment,
    required String variant,
  }) {
    logEvent(
      AnalyticsEvent.experimentExposure,
      parameters: {
        AnalyticsParam.experiment: experiment,
        AnalyticsParam.variant: variant,
      },
    );
  }

  /// Logs that the forced-update / soft-nudge gate was shown ([status] =
  /// `required` or `available`).
  void logAppUpdatePrompt({required String status}) {
    logEvent(
      AnalyticsEvent.appUpdatePrompt,
      parameters: {AnalyticsParam.status: status},
    );
  }
}
