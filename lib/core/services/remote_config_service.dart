import 'package:novaplay/core/constants/app_constants.dart';

/// App-owned remote-config interface for server-tunable values and feature
/// flags (docs/ARCHITECTURE.md §10). Firebase-backed impl wired in Sprint 15.
abstract interface class RemoteConfigService {
  Future<void> init();
  int getInt(String key);
  bool getBool(String key);
}

/// Stub remote config returning the shipped defaults from [_defaults].
class StubRemoteConfigService implements RemoteConfigService {
  static const Map<String, Object> _defaults = {
    RcKeys.interstitialEveryNLevels: 3,
    RcKeys.livesRegenMinutes: 20,
    RcKeys.maxLives: 5,
    RcKeys.coinsPerLevel: 20,
    RcKeys.featureLeaderboards: false,
  };

  @override
  Future<void> init() async {}

  @override
  int getInt(String key) => (_defaults[key] as int?) ?? 0;

  @override
  bool getBool(String key) => (_defaults[key] as bool?) ?? false;
}
