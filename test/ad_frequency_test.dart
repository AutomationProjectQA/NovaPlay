import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/ad_frequency.dart';

void main() {
  group('AdFrequency.shouldShowInterstitial', () {
    test('never shows in the first few levels', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 2,
          levelsSinceLastAd: 10,
          everyN: 3,
        ),
        isFalse,
      );
    });

    test('shows once the cadence is reached', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 8,
          levelsSinceLastAd: 3,
          everyN: 3,
        ),
        isTrue,
      );
    });

    test('does not show before the cadence', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 8,
          levelsSinceLastAd: 2,
          everyN: 3,
        ),
        isFalse,
      );
    });

    test('everyN <= 0 disables interstitials', () {
      expect(
        AdFrequency.shouldShowInterstitial(
          currentLevel: 50,
          levelsSinceLastAd: 99,
          everyN: 0,
        ),
        isFalse,
      );
    });
  });
}
