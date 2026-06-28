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
    ..registerLazySingleton<NotificationService>(NoopNotificationService.new)
    ..registerLazySingleton<CrashReporter>(LoggingCrashReporter.new);

  await getIt<CrashReporter>().init();
  await getIt<RemoteConfigService>().init();
  await getIt<AdsService>().init();
  await getIt<AudioService>().init();
  await getIt<NotificationService>().init();
}
