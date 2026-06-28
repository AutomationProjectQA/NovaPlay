// AdMob load/show/dispose calls are intentionally fire-and-forget.
// ignore_for_file: discarded_futures
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/services/ad_unit_ids.dart';
import 'package:novaplay/core/services/ads_service.dart';

/// Real AdMob implementation (mobile) using `google_mobile_ads`
/// (docs/MONETIZATION.md). Loads rewarded + interstitial ads with Google's test
/// unit IDs; resilient — if AdMob is unavailable every call degrades to a
/// safe fallback (rewards still granted, no interstitial).
class AdMobAdsService implements AdsService {
  bool _available = false;
  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;

  @override
  Future<void> init() async {
    if (!AdUnitIds.supported) return;
    try {
      await MobileAds.instance.initialize();
      // Consent (UMP) would be requested here before loading ads.
      _available = true;
      _loadRewarded();
      _loadInterstitial();
    } on Exception {
      _available = false;
    }
  }

  void _loadRewarded() {
    if (!_available) return;
    RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  void _loadInterstitial() {
    if (!_available) return;
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  @override
  Future<bool> showRewarded(AdPlacement placement) async {
    final ad = _rewarded;
    // Fallback: if no ad is ready (or AdMob unavailable), grant the reward so
    // the value-positive flow is never blocked.
    if (!_available || ad == null) return true;

    var earned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return completer.future;
  }

  @override
  Future<bool> maybeShowInterstitial() async {
    final ad = _interstitial;
    if (!_available || ad == null) return false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );
    await ad.show();
    return true;
  }
}
