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

## 3. AdMob (Sprint 16)

- Create an AdMob app + ad units (rewarded, interstitial) per platform.
- Add the AdMob App ID to `AndroidManifest.xml` and `Info.plist`.
- Replace `StubAdsService` with the `google_mobile_ads` implementation; keep
  `useTestAds` (in `AppEnvironment`) true for dev/staging.

## 4. In-App Purchases (Sprint 13)

- Configure products in Google Play Console / App Store Connect to match the
  catalog in [`docs/MONETIZATION.md`](docs/MONETIZATION.md).

## 5. App icon & splash (Sprint 5/11)

Drop the source art into `assets/images/` (`app_icon.png`,
`app_icon_foreground.png`, `splash_logo.png`), then:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Config for both already lives in `pubspec.yaml`.
