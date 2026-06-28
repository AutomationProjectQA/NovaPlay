import 'package:novaplay/core/constants/app_constants.dart';

/// App-owned remote-config interface for server-tunable values, feature flags,
/// and A/B variants (docs/ARCHITECTURE.md §10, MONETIZATION.md A/B). The
/// Firebase Remote Config-backed implementation is wired when the backend is
/// connected (see SETUP.md).
abstract interface class RemoteConfigService {
  Future<void> init();
  int getInt(String key);
  bool getBool(String key);
  String getString(String key);
}

/// Stub remote config returning the shipped defaults from [_defaults].
class StubRemoteConfigService implements RemoteConfigService {
  static const Map<String, Object> _defaults = {
    RcKeys.interstitialEveryNLevels: 3,
    RcKeys.livesRegenMinutes: 20,
    RcKeys.maxLives: 5,
    RcKeys.coinsPerLevel: 20,
    RcKeys.featureLeaderboards: false,
    RcKeys.featureRewardedContinue: true,
    RcKeys.adsExperimentVariant: 'control',
  };

  @override
  Future<void> init() async {}

  @override
  int getInt(String key) => (_defaults[key] as int?) ?? 0;

  @override
  bool getBool(String key) => (_defaults[key] as bool?) ?? false;

  @override
  String getString(String key) => (_defaults[key] as String?) ?? '';
}
