# store/screenshots — capture spec & automation

Marketing screenshots are **generated, not hand-shot**, so every locale and
device size stays in sync with the build.

## Required sizes

| Store | Device | Resolution (px) | Count |
|---|---|---|---|
| Google Play | Phone | 1080 × 1920 (or 1080 × 2400) | 2–8 |
| Google Play | 7" tablet | 1200 × 1920 | up to 8 |
| Google Play | 10" tablet | 1600 × 2560 | up to 8 |
| App Store | 6.7" iPhone | 1290 × 2796 | 3–10 |
| App Store | 6.5" iPhone | 1242 × 2688 | 3–10 |
| App Store | 12.9" iPad | 2048 × 2732 | up to 10 |

Plus a Play **feature graphic** (1024 × 500) and the App Store has no equivalent.

## Scenes to capture (in each locale: en, es, ar)

1. `01_home` — galaxy map with an active event banner
2. `02_gameplay` — mid-shot with the trajectory preview and lit stars
3. `03_win` — "Constellation lit!" overlay with 3 stars
4. `04_daily` — daily reward ladder + lucky wheel
5. `05_shop` — boosters and lives

Capturing in all three locales also visually verifies the Arabic **RTL** layout.

## Automated capture (recipe)

NovaPlay uses Flutter `integration_test` + the framework's `takeScreenshot`,
driven per-device by fastlane:

- **Android:** `flutter drive` an integration test that navigates the five
  scenes calling `binding.convertFlutterSurfaceToImage()` then
  `binding.takeScreenshot('01_home')`, looped over `--dart-define=LOCALE=…`.
  fastlane `screengrab` collects them per device.
- **iOS:** the same integration test under fastlane `snapshot` across the
  simulator matrix above.
- **Framing:** fastlane `frameit` adds device frames + the localized caption
  strings (kept in `frameit.framefile` / `*.strings`).

> The capture test is intentionally not part of `flutter test` (it needs a
> device/simulator and the integration-test driver). Run it from the release
> machine via `flutter drive`, or in a dedicated CI job, before each submission.

Output lands in `store/screenshots/<store>/<device>/<locale>/`.
