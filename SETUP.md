# NovaPlay — Local & Service Setup

Steps that require accounts/credentials and therefore are **not** committed to
the repo. The app builds and runs fully **without** any of these (Firebase, ads,
and IAP are stubbed) — complete them as their sprints come up.

## 1. Toolchain

- Flutter **3.44.4** stable (`flutter --version`).
- Android: install Android Studio + SDK, then `flutter doctor --android-licenses`.
- iOS (macOS only): install full **Xcode** (not just CLT) + CocoaPods
  (`sudo gem install cocoapods`), then
  `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.

## 2. Firebase (Sprints 4/10/15/17)

Use a **separate Firebase project per flavor** (dev / staging / prod).

```bash
dart pub global activate flutterfire_cli
flutterfire configure \
  --project=novaplay-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.novaplay.novaplay.dev \
  --android-package-name=com.novaplay.novaplay.dev
```

Repeat for staging/prod. This generates `firebase_options_*.dart` and places
`google-services.json` / `GoogleService-Info.plist`. Then call
`Firebase.initializeApp(options: ...)` in `lib/bootstrap.dart`, selecting options
by `AppEnvironment.instance.flavor`.

> These generated files and platform configs are **gitignored** (see below) —
> each developer/CI provides their own.

Once connected, swap the local service implementations in `core/di/injector.dart`:

- **Analytics** → a `FirebaseAnalyticsService` (the typed event catalog in
  `core/services/analytics_events.dart` already maps every event; just forward
  `logEvent` to `FirebaseAnalytics.logEvent`). Today dev uses
  `LoggingAnalyticsService` (console), prod uses `NoopAnalyticsService`.
- **Crash reporting** → a `CrashlyticsCrashReporter` (the error handlers in
  `bootstrap.dart` already route all uncaught errors to `CrashReporter`). Today
  uses `LoggingCrashReporter`.
- **Remote Config** → a `FirebaseRemoteConfigService` (drives ad cadence + A/B
  flags; currently `StubRemoteConfigService` with shipped defaults).

## 3. AdMob (Sprint 16)

AdMob is **fully integrated** with `google_mobile_ads`: `AdMobAdsService`
(rewarded + interstitial, with consent hook) runs on mobile, while web/tests use
`StubAdsService` (the mobile-only SDK is kept out of the web build via a
conditional export). Interstitials are frequency-capped (`AdFrequency`, every
Nth level, never mid-level, Remote Config-tunable). It ships with **Google's
public TEST ad units + test App ID** — so it serves real test ads on a device
**with no AdMob account**.

To go to production:

1. Create an AdMob app + ad units (rewarded, interstitial) per platform.
2. Replace the test App IDs in `android/app/src/main/AndroidManifest.xml`
   (`com.google.android.gms.ads.APPLICATION_ID`) and `ios/Runner/Info.plist`
   (`GADApplicationIdentifier`).
3. Replace the test unit IDs in `lib/core/services/ad_unit_ids.dart`.
4. Implement the consent/UMP flow in `AdMobAdsService.init` and ATT on iOS.

## 4. In-App Purchases (Sprint 13 + post-plan)

- The IAP architecture is wired: catalog in
  [`lib/features/shop/domain/iap_catalog.dart`](lib/features/shop/domain/iap_catalog.dart)
  (`coins_small`, `coins_large`, `starter_bundle`, `remove_ads`), an
  `IapService` interface with a `StubIapService` (no real charge), the
  `PurchaseController` grant flow, a Shop "Premium" section, and Settings →
  Restore purchases. The `remove_ads` entitlement persists in the economy repo
  and suppresses interstitials.
- **To go live:** (1) create products in Google Play Console / App Store Connect
  using the **same product ids** as the catalog; (2) add the `in_app_purchase`
  plugin and implement a `StoreIapService` against it (query/buy/restore +
  purchase-stream verification); (3) register it in DI in place of
  `StubIapService` (mobile-only, like AdMob). Keep web/tests on the stub.
- Balancing lives in [`docs/MONETIZATION.md`](docs/MONETIZATION.md).

## 5. App icon & splash (Sprint 5/11)

Drop the source art into `assets/images/` (`app_icon.png`,
`app_icon_foreground.png`, `splash_logo.png`), then:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Config for both already lives in `pubspec.yaml`.

## 6. Audio (Sprint 12)

The audio pipeline (music, SFX, haptics) is fully wired via `flame_audio`. The
shipped sound files in `assets/audio/` are **silent WAV placeholders** generated
by `tool/generate_placeholder_audio.dart`, so the system runs end-to-end without
audible sound.

To enable real audio, replace the files at the paths fixed in
`lib/core/constants/audio_assets.dart`:

```
assets/audio/music/ambient_loop.wav   (looping background music)
assets/audio/sfx/launch.wav  bounce.wav  star.wav  win.wav  lose.wav
```

Keep the same filenames (or update `AudioAssets`). The volume sliders and Haptics
toggle in Settings control output live; `FlameAudioService` no-ops gracefully if
a file is missing.

## 7. Live features (Sprint 15)

The live/social features ship with **local implementations** behind app-owned
interfaces, so they work offline today and swap to a backend later:

- **Leaderboard** — `LocalLeaderboardService` ranks the player against a fixed
  field. Replace with a `FirestoreLeaderboardService` (read/write a `scores`
  collection) once Firebase is connected; re-bind it in `core/di/injector.dart`.
- **Events / seasonal** — derived locally from the calendar (`activeEvent`). Move
  the event schedule + coin multiplier into **Remote Config** for live control.
- **Daily Challenge** — fully local and deterministic (no backend needed).
- **Push notifications** — `NoopNotificationService`. For real reminders add
  `flutter_local_notifications` (local: lives-full, daily-ready) and wire **FCM**
  via `firebase_messaging` for remote push; implement `NotificationService` and
  re-bind it in DI.

