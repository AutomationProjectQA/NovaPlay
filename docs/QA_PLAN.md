# NovaPlay — QA Plan (Sprints 19 & 20)

> Scope: **Sprint 19 — QA hardening** and **Sprint 20 — Closed Beta**.
> Derived from [`CONCEPT.md`](./CONCEPT.md) (canonical). MVP = core launch-and-light
> mechanic, sectors 1–3 (≥ 60 levels), star ratings, save/load + cloud sync, coins +
> lives + 3 core boosters, daily reward, AdMob rewarded + interstitial, analytics +
> Crashlytics, audio + haptics, EN. Platforms: Android (Google Play) + iOS (App Store).

---

## 1. QA Objectives & Quality Bar

QA exists to verify NovaPlay ships against the four design pillars — **Readable physics,
One more try, Elegant escalation, Calm spectacle** — without regressions, and that every
MVP level is solvable for free (no pay-to-win).

**Definition of "ship-ready" (all must hold):**

| Gate | Target | Source |
|---|---|---|
| Crash-free sessions | **≥ 99.5%** | CONCEPT §13 |
| Crash-free users | ≥ 99.0% | Derived |
| Frame rate | **60 FPS** sustained on mid-tier; no level dips < 50 FPS for > 1 s | CONCEPT §11/§13 |
| Tutorial completion (beta cohort) | ≥ 85% | CONCEPT §13 |
| ANR rate (Android) | < 0.47% (Play "bad behaviour" threshold) | Play policy |
| Open S1/S2 bugs at exit | **0 S1, 0 S2** | This plan §10 |
| Physics determinism | Same input → same outcome across devices/builds | CONCEPT §14 |
| Every MVP level | Solvable with free resources, validated by level QA pass | CONCEPT §12 |
| Cold start (mid-tier) | ≤ 2.5 s to interactive home | Perf target |
| Save integrity | 0 data-loss defects in save/restore + cloud-sync suite | This plan §3 |

**Quality bar philosophy:** failure must feel "so close," never "unfair." Any defect that
makes physics feel non-deterministic or a level unwinnable is **S1 by default**.

---

## 2. Test Strategy & Levels

We use the classic test pyramid adapted for a Flutter + Flame game: many fast unit/logic
tests, fewer widget tests, a thin layer of golden + integration/E2E, plus disciplined
manual exploratory passes for "feel."

| Level | Tooling | What it covers | Where it runs |
|---|---|---|---|
| **Unit** | `flutter_test`, `mocktail` | Pure Dart: economy math (coins/lives/XP), star-rating formula, lives regen timer, booster effects, serialization (freezed/json), Remote Config parsing | CI (every PR) |
| **Flame game-logic** | `flame_test`, `flutter_test` | Deterministic physics: launch vectors, reflection off walls/asteroids, bumper energy, gravity-well curve, black-hole sink, portal momentum, collision → star-lit, win/lose detection, fixed-timestep stepping | CI (every PR) |
| **Widget** | `flutter_test` | Screens & components: HUD, level-select grid + lock states, settings, store, booster picker, modals (win/lose, rewarded-ad offer), Riverpod provider wiring | CI (every PR) |
| **Golden** | `flutter_test` golden, `alchemist`/`golden_toolkit` | Visual regression on key screens & themed states (sector themes, 3-star payoff, empty/locked states) across reference device sizes | CI (nightly + on UI PRs) |
| **Integration / E2E** | `integration_test`, `patrol` (native ad/IAP/permission dialogs) | Full flows on real/emulated devices: cold start → play → win, fail → rewarded ad → extra spark, purchase Remove Ads, sign-in + cloud sync, offline play | CI device farm + nightly |
| **Manual exploratory** | Charters, session notes | Physics "feel," difficulty curve, audio/haptics sync, interruptions, store flows, accessibility, exploratory hunting | Sprint 19 hardening + Sprint 20 beta |

**Determinism note:** Flame world updates run on a **fixed timestep** so physics tests are
reproducible; tests assert positions/outcomes within a tight epsilon. Randomness (lucky
wheel/chest — post-MVP) is seeded in tests.

---

## 3. Test Scope by Feature Area

| Area | In MVP scope | Key risks | Primary test levels |
|---|---|---|---|
| **Gameplay / physics** | Drag-aim + trajectory preview, launch, bounce, walls/asteroids, bumpers, gravity wells, black holes, portals | Non-determinism, tunneling through thin walls, preview vs actual mismatch | Flame logic, integration, manual feel |
| **Level progression & unlock** | Sequential unlock, sector star-gates, 60+ levels, sector finales (20/40/60) | Wrong unlock state, lost progress, ungated sector | Unit, widget, integration |
| **Economy** | Coins, lives (1/20 min, cap 5), XP/player level, daily reward | Currency desync, negative balances, lives over-cap | Unit, integration |
| **Boosters** | 3 core: Guided Line, Slow-Mo, Extra Spark (+ Rewind/Bomb per build) | Effect not applied, double-spend, stuck state | Flame logic, widget, integration |
| **Ads** | AdMob rewarded (extra spark, double coins, free life) + interstitial (≥ every 3rd level, cooldown, never mid-level/first session) | Fill failure, reward not granted, frequency-cap breach, mid-level ad | Integration (Patrol), manual |
| **IAP** | Remove Ads (+ perks); store scaffolding | Purchase not delivered, restore fails, interrupted purchase | Integration (Patrol), manual store accounts |
| **Save/load & cloud sync** | Hive local save; Firestore cloud save; anonymous auth + optional link | Data loss, merge conflict, stale overwrite | Unit, integration, manual |
| **Notifications** | FCM push + local (lives full, daily) | No-show, permission denied handling, deep-link | Integration (Patrol), manual |
| **Settings** | Audio/haptics toggles, reduced motion, account, restore purchases, privacy/consent | Toggle not persisted, consent not honored | Widget, integration |
| **Localization** | EN launch (+ scaffold) | Hardcoded strings, overflow/truncation | Golden, manual, lint for raw strings |

---

## 4. Functional Test Cases (Representative)

> Full suite lives in the test-management tool; this is a representative slice covering the
> core loop and MVP-critical paths. Pre = precondition.

| ID | Area | Precondition | Steps | Expected result |
|---|---|---|---|---|
| TC-001 | Core loop — win | Level 3 loaded, all stars dim, sparks > 0 | Drag to aim; trajectory preview shows; release to launch | Spark follows previewed path; touched dim stars light; when last star lit → Win modal, level cleared, next unlocked |
| TC-002 | Core loop — lose | Level loaded, 1 spark left, 2 stars dim | Launch and miss remaining stars | Spark count hits 0 with stars dim → Lose modal; "Retry" and rewarded-ad offer shown |
| TC-003 | Star rating | Level with 3-star threshold = ≤ 2 sparks | Clear level using exactly 1 spark | Win modal shows 3 stars; star total updated; sector gate progress increments |
| TC-004 | Star rating — partial | Level cleared inefficiently | Clear using max sparks, collect 0 stardust | Win modal shows 1 star; mastery (3-star) not granted |
| TC-005 | Fail → rewarded ad → extra spark | TC-002 Lose modal shown; ad available | Tap "Watch for extra spark"; complete rewarded ad | Ad plays to completion; +1 spark granted; player resumes same board state (not restarted) |
| TC-006 | Rewarded ad — declined | Lose modal shown | Tap "No thanks" / close | No reward; level fails normally; one life consumed |
| TC-007 | Booster — Extra Spark | Pre-level loadout, owns Extra Spark | Equip Extra Spark; start level | Level starts with +1 spark vs base; booster decremented from inventory |
| TC-008 | Booster — Slow-Mo | In-level, Slow-Mo owned | Launch; activate Slow-Mo mid-flight | Spark visibly slows; physics outcome consistent (deterministic); booster consumed |
| TC-009 | Booster — Guided Line | In-level, owns Guided Line | Activate before launch | Extended/longer trajectory preview shown; consumed on use |
| TC-010 | Level unlock | Level N cleared for first time | Return to level select | Level N+1 unlocked & tappable; N+2 still locked; cleared level shows earned stars |
| TC-011 | Sector gate | Player below star threshold for Sector 2 | Tap first Sector-2 level | Locked state shown with required-stars message; entry blocked until threshold met |
| TC-012 | Save / restore (local) | Progress on levels 1–10, app foreground | Kill app; relaunch | Progress, stars, currencies, lives, inventory restored exactly |
| TC-013 | Cloud sync | Signed in (anon linked), progress on Device A | Sign in on Device B with same account | Device B reflects Device A progress after sync; no data loss; newer state wins |
| TC-014 | Offline play | Airplane mode ON, no prior network | Launch app; play levels 1–5 | Game fully playable offline; progress saved locally; queued for sync on reconnect |
| TC-015 | Interstitial cadence | Played 1st & 2nd level of session | Clear 3rd level | Interstitial may show (≥ every 3rd, respecting cooldown); never appears mid-level or during first session |
| TC-016 | Lives regen | Lives = 2, fail a level | Wait one regen interval (20 min) | Lives = 3 (capped at 5); timer resets for next |
| TC-017 | Lives gate | Lives = 0 | Attempt to start a level | Blocked; offered wait-timer, rewarded-ad refill, or refill cost; no level start until life available |
| TC-018 | IAP — Remove Ads | Store open, valid sandbox/test account | Purchase Remove Ads | Purchase completes; interstitials suppressed; advertised perks granted; flag persists across restart |
| TC-019 | Restore purchases | Remove Ads previously bought; reinstall | Settings → Restore Purchases | Remove Ads entitlement restored; no double charge |
| TC-020 | Daily reward | First open of a new day | Open app | Daily reward modal; claim grants coins/booster; not repeatable same day |
| TC-021 | Rewind booster | Mid-level, ≥ 1 shot taken, Rewind owned | Activate Rewind | Last shot undone; board + spark count restored to pre-shot; booster consumed |
| TC-022 | Settings persistence | Audio + haptics ON | Toggle both OFF; restart app | Both remain OFF; no sound/haptics in gameplay |

---

## 5. Edge Cases & Negative Testing

| ID | Scenario | Expected behavior |
|---|---|---|
| EC-01 | No network on launch | App opens offline; cloud features degrade gracefully; clear non-blocking indicator; no crash |
| EC-02 | Airplane mode toggled **mid-shot** | In-flight physics continues unaffected; no stall; sync resumes when back online |
| EC-03 | App killed mid-level | On relaunch: return to level (or pre-level) with no corruption; partial-shot state not persisted as cleared |
| EC-04 | Rewarded ad fails to load | Offer hidden/disabled gracefully ("try again"); player not blocked; fallback path (retry/normal fail) available |
| EC-05 | Interstitial fails to load | Skip silently; never block level transition; respect future cadence |
| EC-06 | IAP interrupted (backgrounded / network drop mid-purchase) | No charge without delivery; pending purchase resolved on relaunch; user not double-charged; entitlement consistent |
| EC-07 | Device clock changed forward | Lives regen does not exploit forward jumps beyond cap; server time used where available; no negative timers |
| EC-08 | Device clock changed backward | Lives/timers do not break or grant infinite lives; clamp to sane values |
| EC-09 | Low memory / OS reclaims app | Graceful save before background; clean restore; no OOM crash on re-entry |
| EC-10 | Incoming **phone call** mid-level | Game pauses; audio ducks/stops; resumes correctly; physics state intact |
| EC-11 | Notification / banner mid-level | Game continues or pauses per design; no input misfire; no crash |
| EC-12 | Rapid input / double-launch tap | Only one spark launches per shot; no double-consume; no race condition |
| EC-13 | Backgrounding during rewarded ad | Reward integrity preserved; no false reward grant; resume cleanly |
| EC-14 | Corrupted local save | Detect, fall back to safe default or cloud; surface recovery, never hard-crash loop |
| EC-15 | Cloud/local conflict (two devices offline then sync) | Deterministic merge (highest progress/stars wins); no silent regression of progress |
| EC-16 | Permission denied (notifications / ATT on iOS) | App fully functional; respects choice; ads/consent behave per consent state |
| EC-17 | Thin-wall / high-speed spark | No tunneling through colliders; continuous collision handling holds |
| EC-18 | Black hole + portal interaction | Defined precedence; no infinite loop / soft-lock; shot ends sanely |

---

## 6. Device & OS Compatibility Matrix

**Tiers:** Low (entry budget), Mid (target — perf bar measured here), High (flagship).

### Android

| Tier | Example devices | OS / SDK | Screen / density | Notes |
|---|---|---|---|---|
| Low | Moto G (4 GB), Galaxy A1x | Android 9 / **API 28 (min)** – 11 | ~720×1600 hdpi | Min-SDK floor; perf floor check |
| Mid | Pixel 6a, Galaxy A5x | Android 12–13 / API 31–33 | 1080×2400 xxhdpi | **Primary 60 FPS target** |
| High | Pixel 8 Pro, Galaxy S2x | Android 14 / API 34 | 1440×3120 xxxhdpi, 120 Hz | High-refresh handling |
| Tablet | Galaxy Tab A | Android 12+ | large / sw600dp | Portrait-locked layout sanity |

Aspect ratios covered: 16:9, 18:9, 19.5:9, 20:9; **punch-hole + notch** safe-area insets verified.

### iOS

| Tier | Example devices | OS | Screen | Notes |
|---|---|---|---|---|
| Low | iPhone SE (2nd/3rd gen) | iOS 15 (min) | 4.7" no-notch | Min-OS floor; small-screen layout |
| Mid | iPhone 12 / 13 | iOS 16 | 6.1" notch | Primary iOS perf check |
| High | iPhone 15 Pro | iOS 17 | 6.1" **Dynamic Island**, ProMotion 120 Hz | Island + high-refresh |
| Tablet | iPad (9th/10th) | iPadOS 16+ | 10.2"/10.9" | Portrait scaling sanity |

Notch / Dynamic Island / home-indicator safe areas validated; HUD never occluded.

---

## 7. Performance Testing

| Metric | Target | How measured | Cadence |
|---|---|---|---|
| **FPS / jank** | 60 FPS sustained; raster+UI thread < 16 ms; no jank spikes > 32 ms during normal play | Flutter DevTools timeline, `--profile` builds, `flutter run --trace-skia`; in-game frame-time overlay; Firebase Performance custom traces per level | Per build on mid-tier + high-refresh device |
| **Memory** | Stable; no growth across 30-min play; peak within device-tier budget | DevTools memory view, Android Profiler / Xcode Instruments; leak check on level reload | Nightly soak |
| **Battery / thermal** | No excessive drain; no thermal throttling in 15-min session | Android Battery Historian, Xcode Energy gauge | Weekly on low + mid tier |
| **Cold start** | ≤ 2.5 s to interactive home (mid-tier) | `flutter run --trace-startup`, Firebase Performance `_app_start` | Per release candidate |
| **Warm start** | ≤ 1.0 s | Resume-to-interactive trace | Per RC |
| **Particle/FX stress** | 3-star payoff + finale FX hold 60 FPS | Manual + timeline on low tier | Per RC |

Mid-tier is the **contractual** FPS bar (CONCEPT §13). Low tier may drop visual FX
(reduced-motion / quality tier) but must stay playable and readable.

---

## 8. Accessibility Testing

| Check | Target / method |
|---|---|
| **Contrast** | Text & key UI ≥ WCAG AA (4.5:1 body, 3:1 large); verify against `DESIGN_SYSTEM.md` tokens |
| **Color-blind** | Star "dim vs lit" and color-locked stars distinguishable by shape/brightness/icon, not hue alone; test with deuteranopia/protanopia/tritanopia simulation |
| **Text scaling** | Layouts hold at OS large/XL font sizes (up to ~130–200%); no truncation of critical labels |
| **Reduced motion** | Honors OS "Reduce Motion"; in-app reduced-motion setting dampens particles/parallax; no essential info conveyed by motion alone |
| **Tap targets** | ≥ 48×48 dp (Android) / 44×44 pt (iOS) for all interactive controls; aim drag tolerant |
| **Screen reader basics** | Menus/buttons/modals have semantic labels (TalkBack/VoiceOver); gameplay board exposes state summary where feasible; no unlabeled icon-only buttons |
| **Audio independence** | No critical feedback by sound alone (paired visual/haptic) |
| **Haptics** | Respect device + in-app haptics toggle |

---

## 9. Regression Suite & Automation Strategy

| Suite | Automated in CI | Manual | Trigger |
|---|---|---|---|
| Unit + Flame logic | ✅ all | — | Every PR (block on red) |
| Widget | ✅ all | — | Every PR |
| Golden | ✅ | spot-check on intentional UI change | UI PRs + nightly |
| Integration / E2E (core loop, fail→ad, IAP, sync, offline) | ✅ smoke subset per PR; full nightly on device matrix | — | PR (smoke) + nightly (full) |
| Ads / IAP native dialogs | ✅ via Patrol on test accounts | edge flows on real store accounts | Nightly + pre-release |
| Performance traces | ✅ automated startup + per-level FPS trace | thermal/battery, low-tier feel | Nightly + RC |
| Accessibility | partial (semantics + contrast lint) | screen-reader, color-blind, scaling | Per RC |
| Exploratory charters | — | ✅ | Sprint 19 + each beta build |
| Level solvability | ✅ headless solver/regression where feasible | designer/QA hand-pass | On level data change |

**Pipeline gates:** PR must pass unit + widget + Flame logic + smoke E2E + lint/format +
golden (or approved update). Nightly publishes a quality dashboard (pass rate, FPS, crash
trend) to the team channel.

---

## 10. Bug Triage & Severity

### Severity definitions

| Sev | Definition | Examples | SLA (triage → fix target) |
|---|---|---|---|
| **S1 — Critical** | Crash, data loss, unwinnable level, money taken without delivery, security/privacy breach, non-deterministic physics | App crash on launch; cleared progress lost; IAP charged no delivery; level unsolvable | Triage < 4 h; fix before any release; **blocks ship** |
| **S2 — Major** | Core feature broken, no reasonable workaround | Rewarded ad doesn't grant reward; cloud sync overwrites progress; booster has no effect | Triage < 1 day; **blocks ship** |
| **S3 — Minor** | Feature degraded, workaround exists | Wrong star count in one modal; rare layout overflow; minor audio desync | Fix this or next sprint |
| **S4 — Trivial/Polish** | Cosmetic, low impact | Slight color mismatch; copy typo; sub-optimal animation timing | Backlog / opportunistic |

### Bug lifecycle

`New → Triaged (sev + owner) → In Progress → In Review → Verified (QA) → Closed`
(or `Reopened` / `Won't Fix` / `Duplicate` / `Cannot Reproduce`). Every bug carries: build
number, device/OS, repro steps, expected vs actual, logs/Crashlytics ID, screenshot/video.

### Exit criteria (Sprint 19 → enter beta)

- 0 open **S1**, 0 open **S2**.
- ≤ agreed cap of S3 (e.g. ≤ 10), all with owners/dispositions; S4 triaged.
- Crash-free ≥ 99.5% on internal builds; FPS bar met on mid-tier.
- Full regression suite green; all MVP TCs (§4) executed with pass record.
- Every MVP level passes solvability + 3-star reachability review.

---

## 11. Closed Beta Plan (Sprint 20)

**Goals:** validate retention & tutorial completion in the wild, catch device-specific
crashes/perf issues, sanity-check ad cadence & IAP flows on real accounts, and gather
qualitative "feel"/difficulty feedback before production.

| Aspect | Plan |
|---|---|
| **Cohort** | 50–200 testers: internal team, friends-and-family, and a small recruited casual-puzzle audience (18–45, matching CONCEPT §10), spread across Android + iOS and low/mid/high tiers |
| **Distribution — Android** | Play Console **Internal testing** track first (team), then **Closed testing** track (tester email lists / Google Group) |
| **Distribution — iOS** | **TestFlight** — internal group, then external group (with Beta App Review) |
| **Build cadence** | New beta build per fix batch; staged from internal → closed; release notes each build |
| **Feedback channels** | In-app "Send feedback" (deep link), TestFlight feedback + screenshots, a survey (tutorial clarity, difficulty, fun, bugs), and a triage Slack/Discord channel |
| **Telemetry to watch** | D1/D7 retention, tutorial completion %, level fail/quit funnel & drop-off levels, session length & count, crash-free %, ANR, FPS traces, rewarded-ad opt-in rate, interstitial impressions vs cap, IAP attempts/success, sync success rate |
| **Success criteria** | Crash-free ≥ 99.5%; tutorial completion ≥ 85%; D1 trending ≥ 40%; no S1/S2 from cohort unresolved; no level with abnormal drop-off/“unfair” complaints; ad cadence within caps; no IAP delivery failures |
| **Iteration loop** | Weekly: read telemetry + feedback → triage (severity per §10) → fix highest-impact (crashes, blocked levels, difficulty spikes) → ship new beta build → re-measure. Tune difficulty/economy/ad cadence via **Remote Config** where possible (no rebuild) |

**Exit from beta → production-ready (hands to [`RELEASE_PLAN.md`](./RELEASE_PLAN.md)):**
success criteria met for ≥ 1 full iteration, store assets ready (Sprint 21), and release
checklist green.

---

*See also: [`CONCEPT.md`](./CONCEPT.md) · [`PRD.md`](./PRD.md) ·
[`LEVEL_DESIGN.md`](./LEVEL_DESIGN.md) · [`ARCHITECTURE.md`](./ARCHITECTURE.md) ·
[`MONETIZATION.md`](./MONETIZATION.md) · [`ANALYTICS.md`](./ANALYTICS.md) ·
[`RELEASE_PLAN.md`](./RELEASE_PLAN.md)*
