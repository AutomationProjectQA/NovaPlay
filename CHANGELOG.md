# Changelog

All notable changes to NovaPlay. Format follows [Keep a Changelog](https://keepachangelog.com);
versions track the pubspec `X.Y.Z+build`. Bump with `dart run tool/bump_version.dart`.

## [Unreleased]

## [1.0.0+1] — 2026-06-29

First public release.

### Added
- **Gameplay** — drag-to-aim slingshot with a custom deterministic physics
  engine (gravity wells, black holes, bumpers, portals); undo/rewind, restart,
  hint, and extra-spark continue.
- **Content** — 100 handcrafted levels across 5 cosmic sectors with Supernova
  finales and a 0–3 star rating.
- **Economy** — coins, stardust, lives (with regeneration), XP/levels, and 5
  boosters; a functional shop.
- **Retention & live-ops** — daily rewards + streaks, daily challenge, daily
  missions, achievements, lucky wheel & chest, seasonal events, leaderboard.
- **Monetization** — AdMob rewarded + frequency-capped interstitials (fair, no
  pay-to-win).
- **Analytics & stability** — typed GA4 event taxonomy and crash reporting with
  global error handlers.
- **Polish** — particle/juice effects, audio + haptics, reduced-motion support.
- **Accessibility** — screen-reader labels and 48dp touch targets on key UI.
- **Localization** — full UI in English, Español, and العربية (with RTL).
- **Store readiness** — smart in-app review prompt, localized store metadata,
  privacy manifest, and a fastlane release pipeline.

### Notes
- Firebase (Analytics/Crashlytics/Remote Config) and AdMob ship behind swappable
  interfaces and use stubs/test IDs until production credentials are wired
  (see `SETUP.md`).
