# QA_REPORT.md — NovaPlay QA Pass (Sprint 19)

> Execution report for the [QA_PLAN.md](QA_PLAN.md) test strategy. Records what
> was verified, the automated coverage, the accessibility audit (with accepted
> deviations), the edge-case matrix, and the known-issues / deferred list.
>
> **Status: PASS** — `flutter analyze` clean · **109 automated tests green** ·
> `flutter build web` succeeds (fonts tree-shaken 99%).

## 1. Automated test suite

16 test files, **109 tests**, all passing. Run with `flutter test`.

| Area | File | Tests | Covers |
|---|---|--:|---|
| Edge cases / regression | `edge_cases_test.dart` | 26 | Boundaries across all pure logic (this sprint) |
| Rewards | `rewards_test.dart` | 10 | Daily ladder, missions, achievements, roller |
| Economy | `economy_test.dart` | 9 | Wallet, lives regen, XP, boosters |
| Game session | `game_session_test.dart` | 8 | State machine, results, undo/restart |
| Accessibility | `accessibility_test.dart` | 8 | Semantic labels, tap targets (this sprint) |
| Physics | `physics_engine_test.dart` | 7 | Reflection, anti-tunnel, triggers, preview |
| Progress | `progress_test.dart` | 6 | Best-stars, unlock derivation |
| Live ops | `live_test.dart` | 5 | Daily challenge, events, leaderboard |
| Design system | `design_system_test.dart` | 5 | formatCount, widget rendering |
| Game (Flame) | `nova_game_test.dart` | 4 | Mount, win, undo, restart in-engine |
| Navigation | `navigation_test.dart` | 4 | Sectors, settings round-trip |
| Audio | `audio_test.dart` | 4 | Service contract, settings sync |
| Analytics | `analytics_test.dart` | 4 | Typed taxonomy, GA4 naming |
| Ads | `ad_frequency_test.dart` | 4 | Interstitial cadence rules |
| Level content | `levels_content_test.dart` | 3 | 100 levels parse + difficulty curve + minified |
| Smoke | `widget_test.dart` | 2 | App boots |

**Strategy:** all date/random/physics/balancing logic is implemented as pure
functions and tested with fixed inputs (seeded `Random`, fixed clocks). Stateful
repositories use a nullable Hive box that falls back to an in-memory map, so
Riverpod notifiers round-trip in tests without a real Hive.

## 2. Functional verification (manual / scripted)

| Flow | Result | Notes |
|---|---|---|
| First launch → onboarding → Level 1 tutorial | ✅ | Tutorial persists `tutorialSeen` |
| Aim → launch → light all stars → Win overlay | ✅ | Coins + XP credited; star rating correct |
| Run out of sparks → Lose → Extra Spark continue | ✅ | Booster consumed; engine grants spark |
| Lose → life consumed; refill sheet when empty | ✅ | Ad / coins / full-refill paths |
| Lives regen over time + cap at 5 | ✅ | Timer stops at cap (Sprint 18) |
| Pause / resume / app-background snapshot | ✅ | Session restored from Hive |
| Undo / rewind / in-place restart | ✅ | Deterministic re-simulation |
| Daily reward claim + streak + missed-day reset | ✅ | Ladder wraps at day 7 |
| Daily challenge / events / leaderboard | ✅ | Deterministic per day |
| Shop: buy booster / convert stardust / refill | ✅ | Balances guarded (no overspend) |
| Interstitial between levels (capped) | ✅ | Never before level 4, every-N cadence |
| Settings persist (audio / haptics / reduced motion) | ✅ | Live-synced to game |
| Locked-level deep link is redirected | ✅ | Router guard on `continueLevel` |

## 3. Device / OS matrix

Target matrix per QA_PLAN.md. Logic + web build are CI-verified here; on-device
passes are tracked as the project gains signing/store access (see RELEASE_PLAN).

| Platform | Min | Target | Status |
|---|---|---|---|
| Android | API 23 (6.0) | API 34 | Logic + web ✅; on-device pending SDK/signing |
| iOS | 13 | 17 | Logic + web ✅; on-device pending Xcode/signing |
| Web | evergreen | — | **Build ✅** (release build green) |
| Form factors | 360×640 → tablet | — | Board is a fixed-resolution camera (`AspectRatio 100:160`), letterboxed — no layout breakage across sizes |

> The game world uses Flame's fixed-resolution camera, so gameplay is
> resolution-independent; only the surrounding Flutter chrome is responsive.

## 4. Accessibility audit

Audited against WCAG-style mobile guidance. Fixes landed this sprint:

| Item | Status | Detail |
|---|---|---|
| Screen-reader labels on info widgets | ✅ Fixed | `CurrencyBadge` ("1240 coins"), `LivesPill` ("2 of 5 lives, next in 3m 5s"), `StarTriad`/`StarMeter` ("2 of 3 stars"), `LevelNode` ("Level 7, cleared, 3 of 3 stars" / "locked") now carry merged `Semantics` labels; decorative icons are excluded |
| Interactive elements expose button semantics | ✅ Fixed | Currency `+`, lives pill, level nodes announce as buttons; locked nodes announce as disabled |
| Icon-only buttons labelled | ✅ | `NovaIconButton` carries a `tooltip` (semantic label) |
| Minimum 48×48 touch target | ✅ (primary) | `NovaIconButton` enforces 48dp; verified by test |
| Reduced motion | ✅ | Honors `MediaQuery.disableAnimations`; skips bloom, particle bursts, node breathing |
| Color is never the sole signal | ✅ | Locked = lock icon; stars = filled/outline shape; lives = count text |
| Text scaling | ✅ | Uses `TextStyle`/theme; no hard-locked font heights in chrome |

**Accepted deviation (documented, not a defect):** the top-HUD currency/lives
*pills* are ~28dp tall — below the 48dp target — to preserve the compact game
HUD. This is an established pattern for game HUDs; the primary, full-size
affordances for the same actions (the Shop screen, the lives refill sheet) meet
the 48dp target. Tracked for revisit if user testing surfaces mis-taps.

## 5. Edge-case coverage matrix

Locked down by `edge_cases_test.dart` this sprint:

| Domain | Edge cases verified |
|---|---|
| Lives regen | Backwards clock grants nothing · year-long gap caps at max · already-full resets anchor · partial-interval remainder carried |
| Economy | `canAfford` inclusive at exact price · first-clear vs replay coin math · finale XP bonus · XP level derivation exact at boundaries (149/150) |
| Daily reward | First-ever claim · consecutive advance · missed-day reset · double-claim blocked · 7-day ladder wrap |
| Ad frequency | Suppressed before min level · disabled when cadence ≤ 0 · fires exactly at cadence |
| Reward roller | Seed-deterministic · only returns provided rewards · zero total weight → empty |
| Reward format | Empty → "Nothing" · multi-part join |
| Live content | Daily challenge stays in 1..N and wraps · weekend Double Coins, weekday none |
| Physics | Fast diagonal shot never escapes the board (anti-tunnel) · `previewPath` deterministic and non-mutating |

## 6. Regression checklist (run before each release)

- [ ] `flutter analyze` → **No issues found!**
- [ ] `flutter test` → all green
- [ ] `flutter build web` → built, fonts tree-shaken
- [ ] First-run onboarding + Level 1 tutorial
- [ ] Win / lose / continue / undo / restart in a real level
- [ ] Daily reward, daily challenge, shop purchase, settings persistence
- [ ] Interstitial appears only after level 4 on cadence
- [ ] TalkBack/VoiceOver sweep of Home map + HUD (labels read correctly)
- [ ] Reduced-motion on: no bloom/particles/breathing

## 7. Known issues & deferred

| Item | Severity | Disposition |
|---|---|---|
| HUD pill touch targets < 48dp | Low | Accepted deviation (§4); revisit post user-testing |
| On-device Android/iOS passes | — | Pending signing/store setup (RELEASE_PLAN.md) |
| Silent placeholder audio | Low | Replace with compressed OGG before launch (PERFORMANCE.md §6) |
| Firebase services stubbed (Analytics/Crashlytics/RC/FCM) | — | By design; swap points in SETUP.md |
| Round reflective asteroids, moving obstacles | — | Deferred mechanics (post-MVP) |

No open **blocking** or **high-severity** defects. The build is functionally
complete and stable for the soft-launch track.
