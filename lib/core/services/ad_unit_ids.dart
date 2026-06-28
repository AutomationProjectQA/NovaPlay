import 'package:flutter/foundation.dart';

/// AdMob ad unit IDs. Ships with **Google's public test unit IDs** (no AdMob
/// account needed — they serve real test ads on a device). Swap in production
/// unit IDs once the AdMob app is created (docs/SETUP.md, MONETIZATION.md).
abstract final class AdUnitIds {
  // Google's official test ad units.
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  /// Whether AdMob can run on the current platform (mobile only).
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get rewarded => defaultTargetPlatform == TargetPlatform.iOS
      ? _testRewardedIos
      : _testRewardedAndroid;

  static String get interstitial => defaultTargetPlatform == TargetPlatform.iOS
      ? _testInterstitialIos
      : _testInterstitialAndroid;
}
