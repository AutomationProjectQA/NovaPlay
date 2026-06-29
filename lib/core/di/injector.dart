import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/core/logging/app_logger.dart';
import 'package:novaplay/core/services/ad_unit_ids.dart';
import 'package:novaplay/core/services/ads_admob_service.dart';
import 'package:novaplay/core/services/ads_service.dart';
import 'package:novaplay/core/services/analytics_service.dart';
import 'package:novaplay/core/services/audio_service.dart';
import 'package:novaplay/core/services/crash_reporter.dart';
import 'package:novaplay/core/services/haptics_service.dart';
import 'package:novaplay/core/services/leaderboard_service.dart';
import 'package:novaplay/core/services/notification_service.dart';
import 'package:novaplay/core/services/remote_config_service.dart';
import 'package:novaplay/core/services/review_service.dart';

/// The global service locator.
final GetIt getIt = GetIt.instance;

/// Registers app singletons. For now this is hand-wired; as features grow,
/// migrate to `injectable` codegen (`dart run build_runner build`) and call the
/// generated `getIt.init()` here (docs/ARCHITECTURE.md §6).
Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<AppLogger>(AppLogger.new)
    ..registerLazySingleton<AnalyticsService>(
      // Observable in dev; no-op until Firebase Analytics is wired (SETUP.md).
      AppEnvironment.instance.isProd
          ? NoopAnalyticsService.new
          : LoggingAnalyticsService.new,
    )
    ..registerLazySingleton<RemoteConfigService>(StubRemoteConfigService.new)
    ..registerLazySingleton<AdsService>(
      AdUnitIds.supported ? AdMobAdsService.new : StubAdsService.new,
    )
    ..registerLazySingleton<AudioService>(FlameAudioService.new)
    ..registerLazySingleton<HapticsService>(PlatformHapticsService.new)
    ..registerLazySingleton<LeaderboardService>(LocalLeaderboardService.new)
    ..registerLazySingleton<ReviewService>(
      // Native review flow on mobile; no-op on web/desktop/tests.
      AdUnitIds.supported ? InAppReviewService.new : NoopReviewService.new,
    )
    ..registerLazySingleton<NotificationService>(NoopNotificationService.new)
    ..registerLazySingleton<CrashReporter>(LoggingCrashReporter.new);

  // Critical path — these gate first-frame behaviour, so block on them, but run
  // them together rather than one-after-another: the crash reporter must exist
  // before the global error handlers, and Remote Config gates the A/B flags the
  // first screen reads (docs/PERFORMANCE.md startup budget).
  await Future.wait([
    getIt<CrashReporter>().init(),
    getIt<RemoteConfigService>().init(),
  ]);

  // Non-critical — the ad SDK, audio preload, and notification channels don't
  // gate the first frame, so warm them up in the background to keep startup off
  // their latency. Failures are reported, never fatal.
  unawaited(_warmUpDeferredServices());
}

/// Initialises services that aren't needed for the first frame. Each is guarded
/// independently so one slow/failing SDK can't block or cancel the others.
Future<void> _warmUpDeferredServices() async {
  final crash = getIt<CrashReporter>();
  Future<void> guard(Future<void> Function() init) async {
    try {
      await init();
    } on Object catch (error, stack) {
      // A non-critical SDK failing to warm up must not crash startup; report it.
      await crash.recordError(error, stack);
    }
  }

  await Future.wait([
    guard(getIt<AdsService>().init),
    guard(getIt<AudioService>().init),
    guard(getIt<NotificationService>().init),
  ]);
}
