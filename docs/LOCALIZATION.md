# LOCALIZATION.md — NovaPlay i18n / l10n

> Sprint 20 deliverable. How NovaPlay is translated, which locales ship, how to
> add a language or a string, and the RTL story. Tooling: **easy_localization**
> with JSON catalogs under `assets/translations/`.

## 1. Supported locales

| Code | Language | Direction | Status |
|---|---|---|---|
| `en` | English | LTR | Source of truth (complete) |
| `es` | Español (Spanish) | LTR | Complete — **machine-assisted, pending native review** |
| `ar` | العربية (Arabic) | **RTL** | Complete — **machine-assisted, pending native review**; doubles as the RTL test locale |

Configured in [`bootstrap.dart`](../lib/bootstrap.dart):
`supportedLocales: [Locale('en'), Locale('es'), Locale('ar')]`,
`fallbackLocale: Locale('en')`. `MaterialApp.router` wires
`context.locale`, `context.supportedLocales`, and `context.localizationDelegates`
(which include the `flutter_localizations` global delegates — required so Arabic
flips the app to RTL and Material widgets localize).

> ⚠️ The `es`/`ar` strings were produced with machine assistance for the scaffold
> and **must be reviewed by a native speaker before store release** (Arabic
> plural rules in particular — see §5).

## 2. How strings are organised

- One JSON file per locale: `assets/translations/<code>.json`. Flat key → value,
  with nested maps for plurals.
- **Keys are stable identifiers**, not English text, e.g. `win_title`,
  `common_next`, `shop_owned`. Grouped by prefix: `common_*`, `nav_*`, `game_*`,
  `daily_*`, `shop_*`, `lives_*`, `settings_*`, `profile_*`, `tutorial_*`,
  `error_*`, `event_*`, `achievement_*`, `mission_*`, `booster_*`, `a11y_*`.
- **Domain content is keyed by id**, not refactored into the domain layer. A
  presentation widget renders `'achievement_${a.id}'.tr()`, `'mission_${m.id}'`,
  `'event_${e.id}_title'`, `'booster_$name'` (`BoosterType.labelKey`). The domain
  models stay free of any l10n import — they expose ids/keys, the UI resolves them.

## 3. Using translations in code

```dart
import 'package:easy_localization/easy_localization.dart';

Text('win_title'.tr())                         // simple
Text('win_coins'.tr(args: ['$coins']))         // positional {} interpolation
Text('lives_count'.tr(args: ['$cur', '$max'])) // multiple args, in order
Text('lose_stars_dim'.plural(starsRemaining))  // plural (count fills {})
```

Interpolation uses positional `{}` placeholders filled from `args` in order.
Plurals use a nested map (`one` / `other` / …) and `.plural(count)`.

## 4. Switching language

Settings → Language opens a sheet listing each locale by its **autonym**
(`lang_en` = "English", `lang_es` = "Español", `lang_ar` = "العربية" — identical
in every catalog). Selecting one:
1. `context.setLocale(locale)` — easy_localization rebuilds the app **and
   persists the choice** (`saveLocale` defaults on), so it's restored on next
   launch with no extra wiring.
2. Mirrors the code into `settingsProvider` (`SettingsState.languageCode`) so our
   own state stays coherent.
3. Logs a `settings_changed` analytics event.

## 5. RTL (Arabic)

- Direction is automatic: with `flutter_localizations` delegates wired, an Arabic
  locale sets `TextDirection.rtl` app-wide. `Row`/`Column`/`Align` resolve
  start↔end from the ambient direction, so leading-icon-then-text rows mirror
  correctly with no code change.
- **Audited for absolute insets.** Asymmetric left/right padding was converted to
  directional insets so it mirrors: `hub_top_bar` (`EdgeInsetsDirectional.fromSTEB`)
  and the level-select app-bar action (`EdgeInsetsDirectional.only(end:)`).
  Symmetric paddings (`EdgeInsets.symmetric`/`all`, and `fromLTRB` where L == R)
  are direction-safe and left as-is.
- **The game board is direction-neutral.** Gameplay is a fixed-resolution Flame
  camera in world coordinates — physics and aiming do not mirror, which is correct
  (a slingshot puzzle plays the same in any locale).
- **Plurals:** Arabic has six CLDR plural categories (`zero/one/two/few/many/other`).
  The catalog currently provides `one`/`other`; easy_localization falls back to
  `other` for the rest. Acceptable for the two pluralised strings now, but a
  native reviewer should fill the full set before release.

## 6. Adding a new language

1. Copy `assets/translations/en.json` to `<code>.json` and translate every value.
   Keep keys, `{}` placeholders, and plural forms intact.
2. Add `Locale('<code>')` to `supportedLocales` in `bootstrap.dart` and add a
   `lang_<code>` autonym + the locale to the picker list in `settings_screen.dart`.
3. `flutter pub get` is not needed; run `flutter test test/localization_test.dart`
   — it fails if the new file is missing any English key or has a blank value.

## 7. Adding a new string

1. Add the key + English value to `en.json`, then the same key to **every** other
   locale (`localization_test.dart` enforces parity — a missing key fails CI).
2. Reference it with `'key'.tr()` at the **UI call site** (never inside unit-tested
   providers — `tr()` outside an `EasyLocalization` tree returns the raw key).

## 8. Known limitations / follow-ups

| Item | Notes |
|---|---|
| `es` / `ar` native review | Machine-assisted; review before release (§1, §5). |
| Accessibility `Semantics` labels | The `a11y_*` keys exist in all catalogs but the widget `Semantics` labels (currency/lives/stars/level node) are still wired to English literals. Localizing them requires routing `EasyLocalization` through the widget-test harness so `accessibility_test` stays green — tracked as a follow-up. |
| `Reward.summary` | Dynamic reward summaries (e.g. "120 coins · 1 Extra Spark") are composed in the domain layer and remain English. Booster **names** are localized in the shop via `booster_*`; the summary string is not. |
| Dev-only `GalleryScreen` | Behind `!isProd`, never shipped to players — intentionally left in English. |
| Arabic full plural set | Only `one`/`other` provided; fill `zero/two/few/many` on native review. |
| Numerals | Latin digits used in all locales for consistency with the score HUD; Eastern-Arabic numerals are a possible future option. |
```
