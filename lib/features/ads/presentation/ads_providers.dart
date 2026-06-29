import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/ad_frequency.dart';
import 'package:novaplay/core/services/remote_config_service.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';

/// Tracks levels since the last interstitial and decides when the next one
/// fires, using the server-tuned cadence (docs/MONETIZATION.md §2).
final interstitialControllerProvider =
    NotifierProvider<InterstitialController, int>(InterstitialController.new);

class InterstitialController extends Notifier<int> {
  @override
  int build() => 0;

  /// Records a level completion; returns true if an interstitial should run now.
  bool onLevelComplete(int level) {
    // The "remove ads" entitlement suppresses interstitials (rewarded ads stay
    // available — they're opt-in for rewards).
    if (ref.read(removeAdsProvider)) return false;
    final everyN = getIt<RemoteConfigService>().getInt(
      RcKeys.interstitialEveryNLevels,
    );
    final next = state + 1;
    final show = AdFrequency.shouldShowInterstitial(
      currentLevel: level,
      levelsSinceLastAd: next,
      everyN: everyN,
    );
    state = show ? 0 : next;
    return show;
  }
}

/// A/B hook: whether the rewarded "continue" offer is enabled (Remote Config).
final rewardedContinueEnabledProvider = Provider<bool>((ref) {
  return getIt<RemoteConfigService>().getBool(RcKeys.featureRewardedContinue);
});

/// A/B hook: the active ads experiment variant (Remote Config).
final adsExperimentProvider = Provider<String>((ref) {
  return getIt<RemoteConfigService>().getString(RcKeys.adsExperimentVariant);
});
