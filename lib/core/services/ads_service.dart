import 'package:novaplay/core/constants/app_constants.dart';

/// App-owned ads interface (docs/MONETIZATION.md ad strategy). The
/// google_mobile_ads-backed implementation, frequency capping, and consent flow
/// are wired in Sprint 16.
abstract interface class AdsService {
  Future<void> init();

  /// Shows a rewarded ad for [placement]. Resolves true if the reward was
  /// granted (ad watched to completion), false otherwise.
  Future<bool> showRewarded(AdPlacement placement);

  /// Shows an interstitial if frequency rules allow; returns whether one ran.
  Future<bool> maybeShowInterstitial();
}

/// Stub ads implementation: grants rewards instantly and never shows ads.
/// Lets the full gameplay loop run before AdMob is integrated.
class StubAdsService implements AdsService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> showRewarded(AdPlacement placement) async => true;

  @override
  Future<bool> maybeShowInterstitial() async => false;
}
