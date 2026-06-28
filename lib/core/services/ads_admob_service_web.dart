import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/services/ads_service.dart';

/// Web fallback for [AdMobAdsService] — `google_mobile_ads` is mobile-only, so
/// on web this no-ops (the app registers `StubAdsService` there anyway). Exists
/// purely so the conditional export resolves a symbol of the same name.
class AdMobAdsService implements AdsService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> showRewarded(AdPlacement placement) async => true;

  @override
  Future<bool> maybeShowInterstitial() async => false;
}
