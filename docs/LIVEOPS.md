# LIVEOPS.md — Post-launch operations (Sprint 23)

> The playbook for running NovaPlay after launch: what to watch, how to react,
> how to experiment, and the remote levers that change the game without an app
> update. Pairs with [ANALYTICS.md](ANALYTICS.md) (event taxonomy),
> [MONETIZATION.md](MONETIZATION.md) (economy), and [RELEASE_PLAN.md](RELEASE_PLAN.md).

## 1. Health monitoring & alert thresholds

Watch these daily for the first 2 weeks, then weekly. Source: GA4 + Crashlytics
(wired per SETUP.md); the events already emit (ANALYTICS.md).

| Metric | Healthy | ⚠️ Investigate | 🚨 Act now |
|---|---|---|---|
| Crash-free users | > 99.5% | < 99% | < 98% → halt rollout / kill switch |
| Crash-free sessions | > 99.8% | < 99.5% | < 99% |
| ANR rate (Android) | < 0.47% | > 0.47% | > 1% (Play "bad behaviour" threshold) |
| D1 retention | > 35% | < 30% | < 25% |
| D7 retention | > 15% | < 12% | < 8% |
| Avg session length | > 4 min | < 3 min | sharp drop vs baseline |
| Tutorial completion | > 85% | < 75% | < 60% (onboarding broken) |
| Level-1→5 funnel | > 70% | < 60% | steep early cliff |
| ARPDAU | track | — | sudden drop (ad fill / config issue) |

**Reaction ladder:** ⚠️ → open an issue, check recent config/release. 🚨 → halt
the staged rollout (RELEASE_PLAN §9), and if a build is fundamentally broken,
raise `min_supported_build` (the kill switch, §4) to force users onto a fixed one.

## 2. Remote Config — the LiveOps control panel

Server-tunable keys (`RcKeys` + `StubRemoteConfigService` defaults). Changing
these takes effect **without an app update**:

| Key | Default | Purpose |
|---|---|---|
| `interstitial_every_n_levels` | 3 | Ad cadence |
| `lives_regen_minutes` | 20 | Energy economy |
| `max_lives` | 5 | Energy cap |
| `coins_per_level` | 20 | Reward balancing |
| `feature_leaderboards_enabled` | false | Feature flag |
| `feature_rewarded_continue` | true | Feature flag (A/B) |
| `ads_experiment_variant` | control | Ads experiment arm |
| `min_supported_build` | 1 | **Kill switch** (§4) |
| `latest_build` | 1 | Soft update nudge |
| `exp_<key>` | (unset) | Per-experiment override (§3) |

> Always change one lever at a time and annotate the analytics timeline, so a
> metric move is attributable.

## 3. A/B experiments

Framework: `lib/core/experiments/` — assignment is **pure and deterministic per
install** (`assignVariant`), so a player keeps the same bucket and it's fully
unit-tested. Remote Config can pin or disable any experiment server-side.

**Lifecycle**
1. **Define** an `Experiment` (key, weighted `Variant`s, `control`) in the catalog.
2. **Read** the variant via `experimentVariantProvider(experiment)`; branch
   behaviour on the returned id.
3. **Log exposure** with `logExperimentExposure(experiment, variant)` *at the
   point it changes behaviour* (not at assignment) so exposure tracks real impact.
4. **Override** server-side with `exp_<key>` = a variant id / `control` / `auto`
   (deterministic). Use this to ramp, pin a winner, or kill a bad arm instantly.
5. **Decide** on the primary metric (e.g. D7 retention, ARPDAU) with significance;
   roll the winner to 100% by pinning the override, then bake it into defaults.

Seed experiments shipped: `interstitial_cadence` (3/4/5), `first_clear_coins`
(20/30). Treat them as templates.

## 4. Kill switch / forced update

`lib/core/services/update_gate.dart` (`evaluateUpdate`, pure + tested) compares
the running `AppBuild.number` to `min_supported_build` / `latest_build`:

- `updateRequired` (build < min) → **blocking** `ForcedUpdateScreen` at boot
  (wired in `SplashScreen`); the only action is "Update now" → store listing.
- `updateAvailable` (build < latest) → reserved for a future dismissible nudge.

**Use it when:** a shipped build has a data-loss/crash/economy bug. Raise
`min_supported_build` above the bad build; affected users are funneled to update.
A `app_update_prompt` analytics event records each gate.

## 5. Content & event cadence

| Cadence | Activity |
|---|---|
| Daily | Daily reward ladder, daily challenge (already automated, deterministic) |
| Weekly | Rotate the seasonal banner (`activeEvent`); weekend Double Coins |
| Monthly | New level pack (regenerate via `tool/generate_levels.dart`, hand-tune), ASO keyword review (STORE_LISTING §3) |
| Seasonal | Themed events, limited-time cosmetics, leaderboard seasons |
| As-needed | Economy/ads tuning via Remote Config, A/B experiments |

## 6. Release → operate loop

`bump_version` → tag → CI → fastlane beta → soak → staged production (10% → 50% →
100%, watching §1) → monitor → tune via Remote Config / experiments → next pack.
See RELEASE_PLAN §6–§7 for the mechanics.

## 7. Post-launch backlog (beyond the 23-sprint plan)

Cloud save & accounts · IAP (currency packs, remove-ads, season pass) ·
real Firebase/AdMob wiring · the dismissible "update available" nudge ·
Eastern-Arabic numerals option · more sectors/mechanics (moving obstacles,
reflective asteroids) · a creator/level-share mode.
