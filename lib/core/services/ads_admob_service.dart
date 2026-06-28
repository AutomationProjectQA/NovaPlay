// Resolves AdMobAdsService to the real google_mobile_ads implementation on
// mobile (dart:io) and a no-op on web — keeping the mobile-only ad SDK out of
// the web build entirely.
export 'ads_admob_service_io.dart'
    if (dart.library.html) 'ads_admob_service_web.dart';
