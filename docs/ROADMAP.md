# NovaPlay — Product Roadmap

> Derived from [`CONCEPT.md`](./CONCEPT.md) (esp. §12 MVP scope). This roadmap sequences the
> work; `PRD.md` owns exact acceptance criteria and `MONETIZATION.md` owns economy/ads detail.
> Status: **v1.0 — 23-sprint plan COMPLETE (Sprints 0–23)** · Owner: Product

> ✅ **All 23 sprints delivered.** The game is feature-complete, instrumented,
> performance-tuned, QA'd, localized (en/es/ar + RTL), store-ready (signed builds,
> ASO metadata, privacy compliance, fastlane), and operable post-launch (A/B
> experiments, remote kill switch, LiveOps playbook — see [`LIVEOPS.md`](./LIVEOPS.md)).
> Remaining work is external wiring (production Firebase/AdMob/IAP credentials,
> hosted legal URLs) and the post-launch backlog (LIVEOPS §7).

---

## 1. Product Roadmap Overview

NovaPlay is delivered across a **23-sprint plan (Sprint 0–23)** structured in three arcs:

1. **Discovery & Design (S0–S4)** — figure out *what* and *how*: vision, PRD, game design,
   UI/UX, architecture. Output is documentation, not code.
2. **Build (S5–S18)** — implement the MVP: setup, design system, navigation, the core physics
   engine, gameplay, 100-level system + tooling, animation, audio, economy, rewards, live
   features, ads, analytics, and performance.
3. **Ship & Operate (S19–S23)** — QA, beta, store assets, release, and post-launch.

Guiding principles:
- **Engine R&D early and de-risked** (S8) — physics feel is the headline technical risk.
- **Level tooling/data pipeline early** (S10) — 100 handcrafted levels is the headline content
  risk; data-driven levels keep design decoupled from code.
- **Hard MVP boundary** — sectors 1–3 (≥60 levels) ship at v1.0; sectors 4–5 and live-ops extras
  are post-MVP (`CONCEPT.md §12`).
- **Offline-first** throughout; cloud/live features degrade gracefully.

---

## 2. The 23-Sprint Plan

| Sprint | Name | Key deliverables | Output docs |
|---|---|---|---|
| **0** | Product Discovery | Vision, personas, market & competitor analysis, risk register, success metrics, MVP scope. | `VISION.md`, `COMPETITOR_ANALYSIS.md`, `ROADMAP.md` |
| **1** | PRD | Functional requirements, user stories, acceptance criteria, scope lock. | `PRD.md` |
| **2** | Game Design | Mechanics spec, level-design framework, difficulty curve, finales, balancing. | `GAME_DESIGN.md`, `LEVEL_DESIGN.md` |
| **3** | UI/UX | Wireframes, user flows, screen specs (home, level-select, settings, profile, in-game HUD). | `UX_FLOWS.md`, `WIREFRAMES.md` |
| **4** | Architecture | Tech architecture, module boundaries, data models, save/sync design, min SDKs. | `ARCHITECTURE.md` |
| **5** | Project Setup | Flutter project, CI, linting, folder structure, DI (get_it/injectable), env config. | `SETUP.md` |
| **6** | Design System | Theme, color/typography tokens, reusable widgets, "lofi space" visual language. | `DESIGN_SYSTEM.md` |
| **7** | Navigation | GoRouter routes, screen scaffolding, transitions, deep-link readiness. | `NAVIGATION.md` |
| **8** | Core Game Engine | Flame game loop, deterministic 2D physics, trajectory preview, slingshot launch. **Alpha milestone.** | `ENGINE.md` |
| **9** | Gameplay | Win/lose, spark count, dim-star lighting, walls/bumpers, restart/rewind, star scoring. | `GAMEPLAY.md` |
| **10** | Level System (100 levels) | Data-driven level format, **level editor/tooling pipeline**, sectors 1–3 authored (≥60 levels). | `LEVEL_DESIGN.md`, `LEVEL_TOOLING.md` |
| **11** | Animation | Juice: light/particle effects, transitions, "calm spectacle" success payoff. | `ANIMATION.md` |
| **12** | Audio | Lofi-space music, SFX, haptics, audio settings/mixing. | `AUDIO.md` |
| **13** | Economy | Coins, lives/energy, stardust, XP, booster consumables, balancing. | `MONETIZATION.md` (economy) |
| **14** | Rewards | Daily reward / login streak, achievements, missions, chests scaffolding. | `REWARDS.md` |
| **15** | Live Features | Daily Challenge, Remote Config tuning, cloud save/sync, (leaderboard/events scaffolding). | `LIVE_FEATURES.md` |
| **16** | Ads | AdMob rewarded + interstitial, frequency caps, value-positive placements, consent/ATT. | `MONETIZATION.md` (ads) |
| **17** | Analytics | GA4 events, funnels, KPIs instrumentation, Crashlytics. | `ANALYTICS.md` |
| **18** | Performance | 60 FPS pass, memory/battery, cold-start, mid-tier device profiling. | `PERFORMANCE.md` |
| **19** | QA | Test plan, automated + manual tests, device matrix, bug triage. | `QA_PLAN.md` |
| **20** | Beta | Closed/open beta, telemetry review, retention/difficulty tuning. **Beta milestone.** | `BETA_PLAN.md` |
| **21** | Store Assets | Store listings, screenshots, trailer, ASO keywords, age ratings, privacy. | `STORE_ASSETS.md` |
| **22** | Release | Play/App Store submission, compliance, staged rollout. **v1.0 MVP launch.** | `RELEASE_PLAN.md` |
| **23** | Post-Launch | Live-ops, hotfixes, monitoring, sectors 4–5 & post-MVP backlog kickoff. | `POST_LAUNCH.md` |

---

## 3. Release Phases / Milestones

| Milestone | Sprint | Definition of done |
|---|---|---|
| **Alpha — Playable engine** | end of S8 (solidified through S9) | Deterministic physics, drag-to-aim slingshot with trajectory preview, launch-and-light loop, win/lose on a test level. Internal only. |
| **Content-complete MVP** | end of S15–16 | Sectors 1–3 (≥60 levels) playable with economy, rewards, daily reward, ads, save/sync. |
| **Beta** | S20 | Stable build to external testers; analytics + Crashlytics live; tuning underway. |
| **v1.0 — MVP launch** | S22 | Public Play/App Store release of the MVP scope (`CONCEPT.md §12`), EN, staged rollout. |
| **v1.1+ — Post-launch** | S23 onward | Live-ops cadence, hotfixes, and rollout of deferred features. |

---

## 4. MVP vs. Post-MVP Feature Split

Consistent with `CONCEPT.md §12`.

### In MVP (v1.0)
- Core launch-and-light mechanic with trajectory preview.
- **Sectors 1–3 (≥60 levels):** Embers, Nebula, Void.
- Star ratings (efficiency / optional stardust).
- Screens: home, level-select, settings, profile.
- Save/load + cloud sync.
- Coins + lives + 3 core boosters.
- Daily reward.
- AdMob rewarded + interstitial.
- Analytics + Crashlytics.
- Audio + haptics.
- EN locale.

### Deferred to Post-MVP
- **Sectors 4–5 (levels 61–100)** — Pulsar, Singularity.
- Leaderboards.
- Events / seasonal content.
- Lucky Wheel / chests.
- Color-lock & switch mechanics.
- Additional locales.
- IAP cosmetics beyond Remove Ads.

---

## 5. Version 2 / Future Roadmap Ideas

Post-v1.0 growth bets (beyond the committed post-MVP backlog above):

- **Full 100-level vision (v1.1–v1.2):** ship sectors 4–5 with their mechanics — moving
  obstacles, color-locks, multi-hit stars, switches/gates — and the remaining Supernova finales.
- **Live-ops engine (v1.2+):** Daily Challenge expansion, seasonal/themed level packs, limited
  cosmetics, Lucky Wheel + chests, missions (daily/weekly).
- **Social & competition (v1.3+):** leaderboards (friends + global, by stars/event score),
  friend invites, shareable solves.
- **Cosmetics economy (v1.3+):** spark skins, board backgrounds, profile flair driven by XP/player
  level and IAP — expanding the ethical, non-pay-to-win store.
- **Content beyond 100:** new sectors / mechanic families; a community or seasonal level pipeline.
- **Localization expansion:** additional launch locales using the EN scaffold.
- **Platform expansion:** tablet-optimized layouts; explore web/desktop via Flutter where viable.
- **Creator tools (exploratory):** a community level editor leveraging the data-driven level
  pipeline built in S10.
- **Accessibility & comfort:** colorblind-safe palettes, reduced-motion mode, additional haptic
  and audio options — reinforcing the premium, inclusive feel.
