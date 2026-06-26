# NovaPlay — Product Requirements Document (PRD)

| Field | Value |
|---|---|
| **Product** | NovaPlay — a calm-but-clever cosmic physics puzzle for mobile |
| **Tagline** | "Light the constellations." |
| **Document** | Product Requirements Document (PRD) |
| **Version** | v1.0 (MVP) |
| **Status** | Draft — under review |
| **Owner** | _[Product Manager — placeholder]_ |
| **Last updated** | 2026-06-26 |
| **Derives from** | [`CONCEPT.md`](./CONCEPT.md) — **canonical single source of truth**. If anything here conflicts with CONCEPT.md, CONCEPT.md wins. |

### Related documents
- [`CONCEPT.md`](./CONCEPT.md) — Concept Bible (canonical; locked v1.0).
- [`VISION.md`](./VISION.md) — personas, audience, full risk register.
- [`MONETIZATION.md`](./MONETIZATION.md) — ad frequency caps, IAP catalog, monetization targets.
- [`LEVEL_DESIGN.md`](./LEVEL_DESIGN.md) — per-sector difficulty curve and level construction rules.
- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — tech stack details, min SDK targets, module layout.
- [`ROADMAP.md`](./ROADMAP.md) — sprint-by-sprint delivery plan.

> **Scope note on MVP vs Post-MVP.** Per CONCEPT.md §12, MVP v1.0 ships the core launch-and-light mechanic, **sectors 1–3 (levels 1–60)**, star ratings, home/level-select/settings/profile, save/load + cloud sync, coins + lives + 3 core boosters, daily reward, AdMob rewarded + interstitial, analytics + Crashlytics, audio + haptics, and EN locale. Sectors 4–5 (levels 61–100), leaderboards, events/seasonal, Lucky Wheel/chests, color-lock & switch mechanics, additional locales, and IAP cosmetics beyond Remove Ads are **Post-MVP**.

---

## 1. Overview & objectives

### 1.1 Summary
NovaPlay is an offline-first, portrait, one-handed **cosmic physics / trajectory puzzle** for Android and iOS. The player is the **Nova** — a wandering spark of starlight reigniting a dark galaxy. In each level the player **drags to aim** a slingshot (with a trajectory preview), **releases to launch** a spark that travels under simple, deterministic physics, and **lights every dim star** it passes through before running out of a limited number of sparks. The product targets a premium, minimal "lofi space" feel: a quiet board with a joyful, particle-and-sound payoff on success.

Sessions are short (60–180 seconds per level), pick-up-and-play, and fully playable with no network connection; cloud sync is optional. The game is free-to-play, monetized primarily through value-positive opt-in rewarded ads, frequency-capped interstitials, and non-pay-to-win IAP.

### 1.2 Objectives (what v1.0 must achieve)
1. **Prove the core loop.** Deliver a launch-and-light mechanic with readable, deterministic physics that feels satisfying and fair ("so close," never "unfair").
2. **Ship a complete, polished casual experience** across **60 handcrafted levels** (sectors 1–3) with smooth difficulty escalation — one new idea per few levels.
3. **Establish retention foundations** — daily reward, lives/energy gate, star-rating mastery, and progression — to hit casual-puzzle retention benchmarks (D1 ≥ 40%, D7 ≥ 18%, D30 ≥ 7%).
4. **Establish a sustainable, non-intrusive monetization base** — rewarded ads opt-in plus capped interstitials and a Remove Ads IAP — without compromising fairness (every level solvable for free).
5. **Hit quality bars** — 60 FPS on mid-tier devices, fast cold start, crash-free sessions ≥ 99.5%, offline-first reliability with conflict-safe cloud sync.

### 1.3 Objectives — explicitly out of scope for v1.0
Real-time multiplayer, PvP, a real-time boss fight (Supernova finales are harder puzzles with theatrics, not real-time combat), level editor for players, and any pay-to-win mechanics.

---

## 2. Goals & non-goals

### 2.1 Goals
| # | Goal | Success signal |
|---|---|---|
| G1 | Deliver a deterministic, readable core mechanic | 3-star-able levels are reproducibly solvable; same input → same trajectory |
| G2 | Ship sectors 1–3 (60 levels) with elegant escalation | One new mechanic per few levels; sector boundary = small difficulty reset + new idea |
| G3 | Offline-first play with optional, conflict-safe cloud sync | Full play with no network; cloud restore on reinstall/new device |
| G4 | Hit tutorial completion ≥ 85% | Analytics funnel on first-time user experience |
| G5 | Value-positive, capped monetization | Rewarded opt-in used; interstitials respect caps; Remove Ads honored everywhere |
| G6 | Performance & stability bars | 60 FPS mid-tier; crash-free ≥ 99.5%; fast cold start |
| G7 | Star-rating mastery loop drives replay | Players replay for 3 stars; star totals gate sectors |

### 2.2 Non-goals (v1.0)
| # | Non-goal | Rationale / deferral |
|---|---|---|
| NG1 | Sectors 4–5 (levels 61–100) | Post-MVP content drop |
| NG2 | Leaderboards (friends/global) | Post-MVP retention layer |
| NG3 | Events, seasonal content, Lucky Wheel, chests | Post-MVP live-ops |
| NG4 | Color-locked stars, switches/gates, multi-hit-only levels | Mechanics introduced in sectors 4–5 (Post-MVP) |
| NG5 | Locales beyond EN | EN at launch; i18n scaffold only |
| NG6 | IAP cosmetics beyond Remove Ads | Remove Ads (+ perks), coin/stardust packs, booster bundles, optional starter pack in MVP; broader cosmetic catalog Post-MVP |
| NG7 | Real-time multiplayer / PvP / player level editor | Not part of product vision for v1.0 |
| NG8 | Ad mediation | AdMob direct in MVP; mediation later |

---

## 3. Personas summary

Full personas live in [`VISION.md`](./VISION.md). Target audience (CONCEPT.md §10): **casual mobile gamers 18–45**, puzzle and "relaxing skill game" fans (audiences of Two Dots, Flow, Angry Birds-lite, ZigZag, Color Switch). Broad, mass-market, ad-friendly.

Working persona summary (authoritative detail in VISION.md):

| Persona | Snapshot | Primary need |
|---|---|---|
| **"Commuter Casey"** (28, non-payer) | Plays in 2–5 min bursts on transit, often offline. | Instant pick-up-and-play, fair retries, no network dependency. |
| **"Completionist Priya"** (34, light spender) | Wants 3 stars on everything; replays for mastery. | Clear star criteria, progression, optional boosters. |
| **"Relaxer Ravi"** (41, ad-watcher) | Plays to unwind; tolerant of opt-in ads for value. | Calm tone, value-positive rewarded ads, low friction. |

---

## 4. Feature list / feature map

Each feature is tagged **[MVP]** or **[Post-MVP]**. Post-MVP items are listed for completeness and forward-compatibility but are **not** required for v1.0 release.

### 4.1 Onboarding & Tutorial
| Feature | Scope |
|---|---|
| First-run interactive tutorial (drag-to-aim, trajectory preview, release-to-launch, light all stars) | **MVP** |
| Contextual just-in-time hints when a new field element first appears (wall, bumper, gravity well, black hole, portal) | **MVP** (only for mechanics present in sectors 1–3) |
| Frictionless first session (no forced login, no ads in first sessions) | **MVP** |
| "Stuck?" in-level helper offers (booster suggestion / hint) | **MVP** |

### 4.2 Core Gameplay
| Feature | Scope |
|---|---|
| Drag-to-aim slingshot with trajectory preview | **MVP** |
| Release-to-launch spark with deterministic physics | **MVP** |
| Light dim stars on spark contact; win when all lit | **MVP** |
| Limited sparks (shots) per level; lose when sparks exhausted with stars dim | **MVP** |
| Instant Restart; **Rewind** undo-last-shot (booster) | **MVP** |
| Walls/asteroids (reflective bounce) | **MVP** (Lvl 1) |
| Bumpers (energy-adding bounce) | **MVP** (~Lvl 8) |
| Gravity wells (curve path) | **MVP** (~Lvl 18) |
| Black holes / sinks (swallow spark — hazard) | **MVP** (~Lvl 30) |
| Portals / wormholes (teleport, keep momentum) | **MVP** (~Lvl 40) |
| Moving obstacles (timed drift) | **Post-MVP** (~Lvl 50) |
| Color-locked stars | **Post-MVP** (~Lvl 60) |
| Multi-hit stars | **Post-MVP** (~Lvl 70) |
| Switch / gate | **Post-MVP** (~Lvl 80) |
| Optional **stardust** collectibles on board | **MVP** |
| Supernova sector finales (levels 20, 40, 60) | **MVP** for 20/40/60; finales 80/100 **Post-MVP** |

### 4.3 Level System & Progression
| Feature | Scope |
|---|---|
| 100 handcrafted levels in 5 sectors × 20 (Embers, Nebula, Void, Pulsar, Singularity) | **MVP delivers sectors 1–3 (levels 1–60)**; sectors 4–5 **Post-MVP** |
| Sequential unlock (clear a level → next unlocks) | **MVP** |
| Sector gating by total stars earned | **MVP** |
| Star rating per level (0–3) by efficiency (sparks used) and/or stardust collected | **MVP** |
| Level-select map / sector map UI | **MVP** |
| Replay any cleared level for a better star rating | **MVP** |

### 4.4 Economy & Boosters
| Feature | Scope |
|---|---|
| **Coins** (soft currency): earn from clears, stars, daily rewards, rewarded ads; spend on boosters, lives refill, cosmetics | **MVP** |
| **Stardust** (hard/premium currency): sparingly from achievements/events + IAP; spend on premium boosters, exclusive skins, skip | **MVP** (earn paths limited; skins beyond Remove Ads Post-MVP) |
| **Lives (energy)** gate: regenerate over time (1 / 20 min, cap 5); spent on a failed attempt | **MVP** |
| **XP / Player Level**: gained by playing/clearing/missions; unlocks cosmetics & profile flair | **MVP** (basic XP + level; flair catalog minimal) |
| 3 core boosters in MVP: **Extra Spark**, **Rewind**, **Slow-Mo** | **MVP** |
| Additional boosters: **Guided Line**, **Bomb Spark** | **Post-MVP** |
| Pre-level loadout selection | **MVP** |
| In-level "stuck?" booster offers | **MVP** |

> **MVP booster decision:** CONCEPT.md §12 specifies "3 core boosters." This PRD designates **Extra Spark, Rewind, Slow-Mo** as the three MVP boosters (the most universally useful and least content-dependent). Guided Line and Bomb Spark are Post-MVP. This is recorded as an assumption (§10) for sign-off.

### 4.5 Rewards & Live Ops
| Feature | Scope |
|---|---|
| Daily reward / login streak | **MVP** |
| Daily Challenge (one special level/day; streak rewards) | **Post-MVP** |
| Lucky Wheel | **Post-MVP** |
| Chests | **Post-MVP** |
| Achievements | **Post-MVP** (basic scaffold may ship; full set Post-MVP) |
| Missions (daily/weekly) | **Post-MVP** |
| Events & seasonal content | **Post-MVP** |

### 4.6 Monetization (Ads + IAP)
| Feature | Scope |
|---|---|
| Rewarded ads (opt-in, value-positive): extra spark on fail, double coins, free life refill, free daily booster | **MVP** |
| Interstitial ads: between levels, frequency-capped (≥ every 3rd level + cooldown), never mid-level, never first sessions | **MVP** |
| **Remove Ads** IAP (also grants perks) | **MVP** |
| Coin packs / Stardust packs IAP | **MVP** |
| Booster bundle IAP | **MVP** |
| Optional Starter Pack IAP | **MVP** |
| Cosmetic spark skins & background IAP (beyond Remove Ads) | **Post-MVP** |
| Ad mediation | **Post-MVP** |

### 4.7 Settings & Profile
| Feature | Scope |
|---|---|
| Audio settings (music / SFX volume, mute) | **MVP** |
| Haptics toggle | **MVP** |
| Notifications toggle | **MVP** |
| Language selector (EN only at launch; UI present) | **MVP** |
| Restore Purchases | **MVP** |
| Account: anonymous by default, optional link (e.g., Google/Apple) for cloud save | **MVP** |
| Privacy/consent controls (ad consent, data) | **MVP** |
| Profile: avatar/flair, player level, star totals, lifetime stats | **MVP** (minimal flair) |
| Credits, support/contact, version info | **MVP** |

### 4.8 Social / Leaderboards
| Feature | Scope |
|---|---|
| Leaderboards by stars earned and/or event score (friends + global) | **Post-MVP** |
| Share level result / invite | **Post-MVP** |

### 4.9 Notifications
| Feature | Scope |
|---|---|
| Local notifications: lives refilled, daily reward ready | **MVP** |
| Push notifications (FCM) for re-engagement / events | **MVP** infra (FCM wired); campaign content limited; event pushes **Post-MVP** |
| Per-OS notification permission flow | **MVP** |

### 4.10 Accessibility
| Feature | Scope |
|---|---|
| Colorblind-safe palette / non-color cues for stars and elements | **MVP** |
| Adjustable text size / dynamic type support | **MVP** |
| Reduce-motion option (dampen particles/screen shake) | **MVP** |
| Haptics + audio cues as redundant feedback | **MVP** |
| Screen-reader labels on menus/UI (not the play field) | **MVP** (menu/UI); play-field SR support **Post-MVP** |
| One-handed portrait reachability | **MVP** |

---

## 5. Functional requirements

Requirements are testable and grouped by area. Each is tagged **[MVP]** / **[Post-MVP]**.

### 5.1 Onboarding & Tutorial (FR-ONB)
| ID | Requirement | Scope |
|---|---|---|
| FR-ONB-01 | On first launch, the app SHALL start gameplay without requiring sign-in, account creation, or any ad. | MVP |
| FR-ONB-02 | The tutorial SHALL teach, in sequence: drag-to-aim, trajectory preview, release-to-launch, and the win condition "light all dim stars," using guided, interactive steps. | MVP |
| FR-ONB-03 | The tutorial SHALL gate progress on the player performing each taught action (no skipping a step without doing it), but SHALL allow exiting the tutorial after the first successful launch. | MVP |
| FR-ONB-04 | When a new field element first appears in normal play (wall, bumper, gravity well, black hole, portal), the app SHALL show a one-time, dismissible contextual hint explaining its behavior. | MVP |
| FR-ONB-05 | The app SHALL log analytics events for tutorial start, each tutorial step completion, tutorial completion, and tutorial skip/abandon. | MVP |
| FR-ONB-06 | The app SHALL NOT show interstitial ads during the tutorial or the first N sessions (N configured via Remote Config; default 3). | MVP |
| FR-ONB-07 | If a level cannot be cleared after a configurable number of consecutive fails (default 3), the app SHALL offer a "stuck?" helper (booster suggestion or hint), dismissible. | MVP |

### 5.2 Core Gameplay (FR-GAME)
| ID | Requirement | Scope |
|---|---|---|
| FR-GAME-01 | The player SHALL aim by dragging on the screen; while dragging, the app SHALL render a trajectory preview indicating the spark's initial path. | MVP |
| FR-GAME-02 | Releasing the drag SHALL launch one spark along the aimed trajectory and consume one spark from the remaining count. | MVP |
| FR-GAME-03 | The spark SHALL move under deterministic physics: identical aim input on identical level state SHALL produce an identical trajectory. | MVP |
| FR-GAME-04 | A dim star SHALL light when the spark's path intersects it; the level SHALL be won when all dim stars are lit. | MVP |
| FR-GAME-05 | The level SHALL be lost when the remaining spark count reaches zero with one or more stars still dim. | MVP |
| FR-GAME-06 | Walls/asteroids SHALL reflect the spark (elastic-style bounce) without consuming a spark. | MVP |
| FR-GAME-07 | Bumpers SHALL reflect the spark while adding energy/speed to the bounce. | MVP |
| FR-GAME-08 | Gravity wells SHALL continuously curve the spark's path toward them while in range. | MVP |
| FR-GAME-09 | Black holes/sinks SHALL swallow the spark, immediately ending that shot (spark already consumed). | MVP |
| FR-GAME-10 | Portals SHALL teleport the spark to the paired exit, preserving momentum (speed and relative direction). | MVP |
| FR-GAME-11 | The player SHALL be able to **Restart** the level instantly at any time, resetting board state and spark count. | MVP |
| FR-GAME-12 | The **Rewind** booster SHALL undo the last shot, restoring the board and spark count to the pre-shot state, consuming one Rewind charge. | MVP |
| FR-GAME-13 | The **Slow-Mo** booster SHALL slow the spark's simulation speed mid-flight for a bounded duration when activated, consuming one charge. | MVP |
| FR-GAME-14 | The **Extra Spark** booster SHALL grant one additional spark to the current attempt, consuming one charge. | MVP |
| FR-GAME-15 | Stardust collectibles, when present, SHALL be collected when the spark passes through them and SHALL contribute to the star rating and/or coin reward. | MVP |
| FR-GAME-16 | A level SHALL run at the performance target during active simulation (see NFR-PERF-01). | MVP |
| FR-GAME-17 | Supernova finales (levels 20, 40, 60) SHALL present a larger set-piece requiring multiple precise hits with shifting field/hazards, using only mechanics available by that level. | MVP |
| FR-GAME-18 | Moving obstacles, color-locked stars, multi-hit stars, and switch/gate mechanics SHALL be supported by the engine but only authored into Post-MVP levels. | Post-MVP |

### 5.3 Level System & Progression (FR-PROG)
| ID | Requirement | Scope |
|---|---|---|
| FR-PROG-01 | The app SHALL present levels grouped into sectors; MVP exposes sectors 1–3 (Embers, Nebula, Void), levels 1–60. | MVP |
| FR-PROG-02 | Clearing a level SHALL unlock the next sequential level. | MVP |
| FR-PROG-03 | Each sector beyond the first SHALL be gated by a minimum total stars earned; a locked sector SHALL display the stars required and the player's current total. | MVP |
| FR-PROG-04 | Each level SHALL award 0–3 stars based on efficiency (sparks used relative to par) and/or stardust collected, per the level's authored criteria. | MVP |
| FR-PROG-05 | The level-select map SHALL show, per level: lock state, stars earned (0–3), and finale/Supernova marker where applicable. | MVP |
| FR-PROG-06 | The player SHALL be able to replay any cleared level; a higher star result SHALL overwrite the stored result, a lower result SHALL NOT. | MVP |
| FR-PROG-07 | Total stars earned SHALL be recomputed and persisted whenever a level result changes. | MVP |
| FR-PROG-08 | Sectors 4–5 (levels 61–100) SHALL be added Post-MVP without requiring migration of existing saves. | Post-MVP |

### 5.4 Economy & Boosters (FR-ECON)
| ID | Requirement | Scope |
|---|---|---|
| FR-ECON-01 | Coins SHALL be granted for clearing levels, earning stars, claiming daily rewards, and completing eligible rewarded ads. | MVP |
| FR-ECON-02 | Coins SHALL be spendable on boosters and on lives refill (and cosmetics where available). | MVP |
| FR-ECON-03 | Lives SHALL regenerate at 1 per 20 minutes up to a cap of 5; a failed attempt SHALL consume one life. | MVP |
| FR-ECON-04 | When lives are at zero, the app SHALL block starting a new attempt and offer: wait (with countdown), watch a rewarded ad for a free refill, spend coins to refill, or IAP. | MVP |
| FR-ECON-05 | Life regeneration SHALL be computed from wall-clock time and SHALL be tamper-resistant against device clock roll-back (server time used when online; capped offline accrual). | MVP |
| FR-ECON-06 | Stardust SHALL be granted sparingly (limited MVP earn paths) and via IAP; it SHALL be spendable on premium boosters and skip where offered. | MVP |
| FR-ECON-07 | The three MVP boosters (Extra Spark, Rewind, Slow-Mo) SHALL be purchasable with coins and selectable in a pre-level loadout. | MVP |
| FR-ECON-08 | Booster inventory counts SHALL persist locally and sync to cloud when signed in. | MVP |
| FR-ECON-09 | XP SHALL be granted for playing/clearing levels; reaching an XP threshold SHALL increase Player Level and may unlock profile flair. | MVP |
| FR-ECON-10 | All currency and inventory mutations SHALL be atomic and SHALL never produce negative balances; insufficient-balance actions SHALL be rejected with a clear prompt. | MVP |
| FR-ECON-11 | Guided Line and Bomb Spark boosters SHALL be added Post-MVP. | Post-MVP |

### 5.5 Rewards & Live Ops (FR-LIVE)
| ID | Requirement | Scope |
|---|---|---|
| FR-LIVE-01 | The app SHALL offer a daily reward claimable once per calendar day (local), with an escalating login-streak reward table. | MVP |
| FR-LIVE-02 | Missing a day SHALL reset the streak to day 1 per the configured rule (configurable via Remote Config). | MVP |
| FR-LIVE-03 | Daily reward claim SHALL credit the granted coins/items atomically and record the claim date to prevent double-claims. | MVP |
| FR-LIVE-04 | Daily Challenge, Lucky Wheel, Chests, Achievements (full), Missions, and Events SHALL be delivered Post-MVP. | Post-MVP |

### 5.6 Monetization — Ads + IAP (FR-MON)
| ID | Requirement | Scope |
|---|---|---|
| FR-MON-01 | Rewarded ads SHALL be opt-in only and SHALL grant the promised reward only on verified completion; if the ad is dismissed early or fails to load, no reward SHALL be granted and no penalty applied. | MVP |
| FR-MON-02 | Rewarded ad placements SHALL include at minimum: extra spark on fail, double coins on clear, free life refill, and free daily booster. | MVP |
| FR-MON-03 | Interstitial ads SHALL appear only between levels, never mid-level, and SHALL respect a frequency cap (≥ every 3rd level) plus a minimum time cooldown, both configurable via Remote Config. | MVP |
| FR-MON-04 | Interstitials SHALL NOT appear during the first N sessions (Remote Config; default 3) or during the tutorial. | MVP |
| FR-MON-05 | Purchasing **Remove Ads** SHALL permanently disable interstitial ads for that account/device, grant the associated perks, and keep rewarded ads available as opt-in. | MVP |
| FR-MON-06 | IAP catalog SHALL include Remove Ads, coin packs, stardust packs, a booster bundle, and an optional starter pack; all SHALL display localized price from the store. | MVP |
| FR-MON-07 | The app SHALL provide **Restore Purchases**; restoring SHALL re-grant non-consumable entitlements (e.g., Remove Ads). | MVP |
| FR-MON-08 | All IAP SHALL verify the store transaction before granting entitlements and SHALL handle pending/deferred and failed transactions gracefully. | MVP |
| FR-MON-09 | No IAP or ad reward SHALL make any level unsolvable-for-free or otherwise create pay-to-win advantage; boosters only save time/add flair. | MVP |
| FR-MON-10 | Cosmetic skins/backgrounds (beyond Remove Ads) and ad mediation SHALL be Post-MVP. | Post-MVP |

### 5.7 Settings & Profile (FR-SET)
| ID | Requirement | Scope |
|---|---|---|
| FR-SET-01 | Settings SHALL allow independent control of music volume, SFX volume, and a master mute; changes SHALL apply immediately and persist. | MVP |
| FR-SET-02 | Settings SHALL allow toggling haptics; when off, no haptic feedback SHALL fire. | MVP |
| FR-SET-03 | Settings SHALL allow toggling notifications and SHALL deep-link to OS notification settings where appropriate. | MVP |
| FR-SET-04 | Settings SHALL present a language selector (EN only at launch) without breaking layout. | MVP |
| FR-SET-05 | Players SHALL play anonymously by default; Settings SHALL offer optional account linking (e.g., Google/Apple) to enable cross-device cloud save. | MVP |
| FR-SET-06 | Settings SHALL expose privacy/consent controls, including the ability to review/change ad-personalization consent and access the privacy policy. | MVP |
| FR-SET-07 | Profile SHALL display player level, total stars, and lifetime stats (levels cleared, stars, etc.). | MVP |
| FR-SET-08 | Settings SHALL show app version/build and provide a support/contact path. | MVP |

### 5.8 Social / Leaderboards (FR-SOC)
| ID | Requirement | Scope |
|---|---|---|
| FR-SOC-01 | Leaderboards (by stars and/or event score; friends + global) SHALL be delivered Post-MVP. | Post-MVP |
| FR-SOC-02 | Result sharing/invite SHALL be delivered Post-MVP. | Post-MVP |

### 5.9 Notifications (FR-NOT)
| ID | Requirement | Scope |
|---|---|---|
| FR-NOT-01 | The app SHALL request notification permission at a contextually appropriate moment (not on cold first launch), per OS guidelines. | MVP |
| FR-NOT-02 | The app SHALL schedule a local notification when lives reach full and when the daily reward becomes available, subject to the user's notification toggle. | MVP |
| FR-NOT-03 | FCM push infrastructure SHALL be integrated and capable of receiving re-engagement messages; honoring the user's notification preference. | MVP |
| FR-NOT-04 | Event/seasonal push campaigns SHALL be Post-MVP. | Post-MVP |

### 5.10 Accessibility (FR-ACC)
| ID | Requirement | Scope |
|---|---|---|
| FR-ACC-01 | Stars and key field elements SHALL be distinguishable without relying on color alone (shape/icon/label/brightness cues). | MVP |
| FR-ACC-02 | UI text SHALL respect OS dynamic type / text-scaling up to a supported maximum without truncation of critical controls. | MVP |
| FR-ACC-03 | A reduce-motion option SHALL dampen particles and screen shake while preserving gameplay readability. | MVP |
| FR-ACC-04 | Critical feedback (success, fail, star earned) SHALL be conveyed via at least two channels (visual + audio and/or haptic). | MVP |
| FR-ACC-05 | Menu and UI controls SHALL expose screen-reader labels and focus order. | MVP |
| FR-ACC-06 | All primary controls SHALL be reachable one-handed in portrait on common phone sizes. | MVP |

### 5.11 Save / Persistence & Cloud Sync (FR-SAVE)
| ID | Requirement | Scope |
|---|---|---|
| FR-SAVE-01 | All progress (levels cleared, stars, currencies, boosters, lives state, settings) SHALL persist locally and survive app restarts and offline play. | MVP |
| FR-SAVE-02 | When signed in (anonymous or linked) and online, progress SHALL sync to cloud (Firestore) and restore on reinstall or a new device after linking. | MVP |
| FR-SAVE-03 | Sync conflicts SHALL be resolved deterministically (highest-progress-wins: max stars per level, max currency balances, latest settings), never silently destroying earned progress. | MVP |
| FR-SAVE-04 | Cloud sync SHALL be non-blocking; gameplay SHALL never stall waiting on network. | MVP |
| FR-SAVE-05 | A save-data schema version SHALL be stored to support forward migration (e.g., adding sectors 4–5). | MVP |

---

## 6. Non-functional requirements

| ID | Category | Requirement | Target / acceptance |
|---|---|---|---|
| NFR-PERF-01 | Performance | Sustained frame rate during active gameplay simulation on mid-tier devices. | ≥ 60 FPS (allow brief dips ≤ 1% of frames below 60 during heavy particle bursts). |
| NFR-PERF-02 | Performance | Cold start to interactive home. | ≤ 3.0 s on mid-tier reference devices; ≤ 2.0 s on high-tier. |
| NFR-PERF-03 | Performance | Level load (tap level → playable). | ≤ 1.0 s on mid-tier. |
| NFR-PERF-04 | Performance | Memory footprint during gameplay. | Within OS limits; no OOM on 2 GB-class Android devices. |
| NFR-REL-01 | Reliability | Crash-free sessions. | ≥ 99.5% (CONCEPT.md §13), tracked via Crashlytics. |
| NFR-REL-02 | Reliability | ANR / hang rate (Android). | Within Google Play "good" thresholds. |
| NFR-REL-03 | Reliability | No progress loss on crash mid-level. | Cleared progress and currency persisted at safe checkpoints. |
| NFR-OFF-01 | Offline-first | Full single-player game (all available levels, economy, boosters, daily reward claim) playable with no network. | 100% of core loop works offline. |
| NFR-OFF-02 | Offline-first | Network-dependent features (cloud sync, ads, IAP, leaderboards) SHALL degrade gracefully when offline, never blocking play. | No hard blocks; clear, non-modal messaging. |
| NFR-SEC-01 | Security/Privacy | Authentication SHALL default to Firebase anonymous auth; account linking optional. | No PII required to play. |
| NFR-SEC-02 | Security/Privacy | The app SHALL comply with GDPR (and equivalents): consent for personalized ads, data access/deletion path, privacy policy link. | Consent flow via UMP/CMP; documented data deletion. |
| NFR-SEC-03 | Security/Privacy | COPPA / age-appropriate handling: the app SHALL not knowingly target under-13 with personalized ads; ad personalization SHALL respect consent and applicable child-directed settings. | Non-personalized ads when consent absent/declined. |
| NFR-SEC-04 | Security/Privacy | Ad consent SHALL be obtained via a compliant consent management flow before serving personalized ads. | UMP consent collected; respected by AdMob requests. |
| NFR-SEC-05 | Security/Privacy | Server-side data access SHALL be governed by Firestore security rules restricting each user to their own documents. | Rules deny cross-user reads/writes. |
| NFR-LOC-01 | Localization | All user-facing strings SHALL be externalized for localization; EN ships at launch with scaffold for additional locales. | Zero hard-coded display strings in MVP. |
| NFR-LOC-02 | Localization | Layouts SHALL tolerate string length variation (target +30%) without clipping critical UI. | Pseudo-localization smoke test passes. |
| NFR-ACC-01 | Accessibility | The app SHALL meet the accessibility FRs (§5.10): color-independent cues, dynamic type, reduce-motion, redundant feedback, SR labels on UI. | All FR-ACC items verified. |
| NFR-SIZE-01 | App size | Initial download size SHALL be kept small for a casual title. | Android base AAB ≤ 75 MB target (assets streamable where feasible). |
| NFR-BAT-01 | Battery/Thermal | Gameplay SHALL avoid excessive battery drain and thermal throttling. | No sustained max-CPU/GPU; frame pacing capped at 60 FPS; idle screens reduce work. |
| NFR-PRIV-01 | Data minimization | Analytics SHALL collect only what is needed for the metrics in §13 of CONCEPT.md and SHALL respect consent. | GA4 events gated by consent where required. |
| NFR-MAINT-01 | Maintainability/Config | Tunable values (caps, frequencies, life timers, gating thresholds) SHALL be driven by Remote Config to allow live tuning and A/B tests. | Key tunables remotely adjustable without app update. |

---

## 7. User stories

Format: *As a `<persona>`, I want `<goal>` so that `<benefit>`.* Grouped by epic. Personas: **Casey** (commuter/non-payer), **Priya** (completionist/light spender), **Ravi** (relaxer/ad-watcher). "Player" = any.

### Epic A — Onboarding & Tutorial
| ID | Story |
|---|---|
| US-A1 | As a new Player, I want to start playing immediately without signing in, so that I can try the game with zero friction. |
| US-A2 | As a new Player, I want an interactive tutorial that teaches me to aim, preview, and launch, so that I understand the core mechanic before facing real levels. |
| US-A3 | As a new Player, I want a short hint the first time a new element (e.g., gravity well) appears, so that I learn one idea at a time. |
| US-A4 | As Casey, I want no ads in my first sessions, so that my first impression is calm and trustworthy. |

### Epic B — Core Gameplay (playing a level)
| ID | Story |
|---|---|
| US-B1 | As a Player, I want to drag to aim and see a trajectory preview, so that I can predict roughly where my spark will go. |
| US-B2 | As a Player, I want to release to launch a spark that lights stars it passes through, so that I can clear the level by lighting them all. |
| US-B3 | As a Player, I want the physics to behave the same every time for the same aim, so that I can plan precise shots. |
| US-B4 | As Priya, I want optional stardust to collect, so that I have a mastery goal beyond just clearing. |

### Epic C — Failing / Retrying
| ID | Story |
|---|---|
| US-C1 | As a Player, I want to instantly restart a level, so that a missed attempt costs me almost nothing. |
| US-C2 | As a Player, I want to run out of sparks and clearly understand I failed and why, so that I can immediately try again ("one more try"). |
| US-C3 | As a Player who keeps failing, I want a gentle "stuck?" offer, so that I get help without feeling blocked. |

### Epic D — Earning currency
| ID | Story |
|---|---|
| US-D1 | As a Player, I want to earn coins for clearing levels and earning stars, so that I can afford boosters and refills. |
| US-D2 | As Priya, I want stars I earn to count toward unlocking the next sector, so that mastery drives my progression. |
| US-D3 | As a Player, I want to gain XP and level up, so that I feel long-term progression and unlock flair. |

### Epic E — Boosters
| ID | Story |
|---|---|
| US-E1 | As a Player, I want to pick a booster loadout before a level, so that I can prepare for a tricky board. |
| US-E2 | As a Player, I want to use Rewind to undo my last shot, so that one mistake doesn't force a full restart. |
| US-E3 | As a Player, I want Slow-Mo mid-flight, so that I can fine-tune a difficult ricochet. |
| US-E4 | As a Player, I want an Extra Spark when I'm one star short, so that I can finish a "so close" attempt. |

### Epic F — Rewarded ads
| ID | Story |
|---|---|
| US-F1 | As Ravi, I want to watch an optional ad to get an extra spark after failing, so that I can salvage a near-win on my terms. |
| US-F2 | As a Player, I want to optionally double my coin reward by watching an ad, so that I progress faster for free. |
| US-F3 | As a Player, I want to refill lives by watching an ad, so that I can keep playing without paying. |

### Epic G — Daily reward & retention
| ID | Story |
|---|---|
| US-G1 | As a Player, I want a daily reward with a growing login streak, so that I have a reason to return each day. |
| US-G2 | As a Player, I want a notification when my lives are full or my daily reward is ready, so that I come back at the right time. |

### Epic H — Settings & Profile
| ID | Story |
|---|---|
| US-H1 | As a Player, I want to control music/SFX/haptics, so that I can play comfortably in any environment. |
| US-H2 | As a Player, I want to manage ad/privacy consent, so that I control how my data is used. |
| US-H3 | As a Player, I want to see my stars, level, and stats, so that I can track my mastery. |

### Epic I — Cloud save
| ID | Story |
|---|---|
| US-I1 | As Priya, I want to link my account so my progress is backed up, so that I don't lose 60 levels of stars. |
| US-I2 | As a Player, I want my progress restored on a new device after linking, so that I can switch phones safely. |
| US-I3 | As a Player, I want cloud sync to never interrupt my play, so that offline play always feels instant. |

### Epic J — Monetization (IAP)
| ID | Story |
|---|---|
| US-J1 | As Ravi, I want to buy Remove Ads, so that interstitials stop while I keep optional rewarded ads. |
| US-J2 | As a Player, I want to restore purchases on a new device, so that my Remove Ads entitlement follows me. |

---

## 8. Acceptance criteria

Given/When/Then for the most important stories. All criteria are testable.

### AC-1 — Core gameplay loop (US-B1, US-B2, US-B3)
- **Given** a level with N dim stars and S sparks, **when** the Player drags on the board, **then** a trajectory preview renders from the launch point along the aimed direction and updates in real time as the drag moves.
- **Given** the Player is aiming, **when** the Player releases, **then** exactly one spark launches along the previewed initial direction and the remaining spark count decreases by one.
- **Given** a spark in flight, **when** its path intersects a dim star, **then** that star lights and remains lit for the rest of the attempt.
- **Given** all dim stars are lit, **when** the last one lights, **then** the level is marked won, the success payoff (light/particles/sound) plays, and the result screen with star rating appears.
- **Given** identical level state and an identical aim vector, **when** the spark is launched twice, **then** both trajectories are identical (deterministic).

### AC-2 — Tutorial (US-A1, US-A2)
- **Given** a first-ever launch of the app, **when** the app opens, **then** no sign-in and no ad are shown and the tutorial begins.
- **Given** the tutorial step "drag to aim," **when** the Player has not yet dragged, **then** the step cannot be completed and a guided prompt is shown.
- **Given** the Player completes each tutorial action in sequence (aim → preview → launch → light all stars), **when** the final star is lit, **then** the tutorial is marked complete and a `tutorial_complete` analytics event fires.
- **Given** the tutorial is in progress, **when** the Player chooses to skip after the first successful launch, **then** the tutorial ends and a `tutorial_skip` event fires; before the first successful launch, skip is unavailable.

### AC-3 — Fail + rewarded ad for extra spark (US-C2, US-F1)
- **Given** the Player's last spark is consumed with stars still dim, **when** the simulation ends, **then** a fail state is shown with the reason and a retry option, plus an opt-in "watch ad for an extra spark" offer (when an ad is available and Remove-Ads-rewarded behavior permits).
- **Given** the extra-spark ad offer, **when** the Player opts in and the ad completes successfully, **then** one extra spark is granted to the same attempt with board state preserved and play resumes.
- **Given** the ad offer, **when** the Player dismisses the ad early or the ad fails to load, **then** no extra spark is granted, no life/currency penalty is applied, and the Player returns to the fail screen.
- **Given** lives are involved, **when** the attempt failed, **then** exactly one life is consumed for the failed attempt (per FR-ECON-03), independent of the ad outcome.

### AC-4 — Star rating (US-B4, US-D2)
- **Given** a cleared level with an authored par and/or stardust set, **when** the result is computed, **then** stars (0–3) are assigned per the authored efficiency (sparks used vs par) and/or stardust-collected criteria.
- **Given** a previous best of X stars on a level, **when** the Player replays and earns Y stars, **then** the stored result becomes max(X, Y) and total stars are recomputed.
- **Given** total stars change, **when** they cross a sector gate threshold, **then** the gated sector becomes unlocked and reflects the new state in level-select.

### AC-5 — Save / load & cloud sync (US-I1, US-I2, US-I3)
- **Given** progress made offline, **when** the app is killed and relaunched offline, **then** all progress (levels, stars, currencies, boosters, lives state, settings) is intact.
- **Given** a signed-in Player who comes online, **when** sync runs, **then** local and cloud state merge with highest-progress-wins (max stars per level, max balances, latest settings) and no earned progress is lost.
- **Given** a fresh install on a new device, **when** the Player links the same account, **then** cloud progress is restored.
- **Given** any sync operation, **when** it is in progress, **then** gameplay remains fully interactive and never blocks on the network.

### AC-6 — Level unlock & sector gating (US-D2)
- **Given** an uncleared level, **when** the Player clears it, **then** the next sequential level unlocks immediately.
- **Given** a locked sector with threshold T stars, **when** the Player's total stars are below T, **then** the sector is locked and shows "T stars required" with current total.
- **Given** the Player's total reaches or exceeds T, **when** level-select is opened, **then** the sector is unlocked and its first level is playable.

### AC-7 — Interstitial frequency cap (FR-MON-03, FR-MON-04, US-J1)
- **Given** the configured cap of "≥ every 3rd level" with cooldown, **when** the Player finishes levels, **then** an interstitial is eligible no more often than every 3rd level completion and not before the cooldown elapses, and never mid-level or during the first N sessions/tutorial.
- **Given** the Player owns Remove Ads, **when** any level completes, **then** no interstitial is shown, while opt-in rewarded ads remain available.

### AC-8 — Lives gate & refill (US-F3, FR-ECON-03/04/05)
- **Given** lives below cap, **when** 20 minutes of wall-clock elapse, **then** one life is restored, up to the cap of 5.
- **Given** lives at zero, **when** the Player tries to start a level, **then** play is blocked and the Player is offered: wait (countdown), watch a rewarded ad for a free refill, spend coins, or IAP.
- **Given** the device clock is rolled back, **when** life accrual is computed, **then** accrual is not inflated (server time when online; bounded offline accrual).

---

## 9. Release criteria / Definition of Done (MVP v1.0)

The MVP is releasable when **all** of the following hold:

**Content & scope**
1. Sectors 1–3 (levels 1–60) are authored, solvable, and 3-star-achievable; Supernova finales at levels 20, 40, 60 implemented.
2. All field elements required by sectors 1–3 (dim star, wall/asteroid, bumper, gravity well, black hole, portal) function per FR-GAME.
3. Tutorial and contextual hints for sector 1–3 mechanics are implemented (FR-ONB).

**Core loop & systems**
4. Drag-aim → preview → launch → light → win/lose loop is complete and deterministic (AC-1).
5. Star ratings, sequential unlock, and star-gated sectors work (AC-4, AC-6).
6. Coins, stardust, lives (1/20 min, cap 5), XP/player level, and the 3 MVP boosters (Extra Spark, Rewind, Slow-Mo) work with atomic, non-negative balances (FR-ECON).
7. Daily reward / login streak works with double-claim protection (FR-LIVE).

**Save, sync, accounts**
8. Offline-first local save persists across restarts; cloud sync with highest-progress-wins conflict resolution; restore on new device after linking (AC-5). Anonymous auth default; optional linking.

**Monetization**
9. AdMob rewarded (extra spark, double coins, life refill, daily booster) and interstitial (capped, never mid-level, not in first N sessions/tutorial) integrated; Remove Ads + coin/stardust packs + booster bundle + optional starter pack IAP with Restore Purchases and store verification (FR-MON, AC-3, AC-7). No pay-to-win.

**Quality & compliance**
10. Performance: ≥ 60 FPS in gameplay on mid-tier reference devices; cold start within NFR-PERF-02 (AC verified on the device matrix).
11. Stability: crash-free sessions ≥ 99.5% in pre-release cohort; no known P0/P1 crashes.
12. Privacy/consent: UMP/CMP ad-consent flow live; Firestore security rules restrict per-user data; privacy policy linked; data deletion path documented (NFR-SEC).
13. Accessibility: color-independent cues, dynamic type, reduce-motion, redundant feedback, UI screen-reader labels (FR-ACC).
14. Localization: all strings externalized; EN complete; pseudo-loc smoke test passes.
15. Analytics & Crashlytics wired for the §13 CONCEPT metrics (tutorial funnel, sessions, retention proxies, ad/IAP events).
16. App size within NFR-SIZE-01; store listings, age ratings, and required disclosures (data safety / privacy nutrition) prepared.

**Process**
17. All MVP-tagged FRs pass their acceptance criteria; all open questions in §10 are resolved or explicitly accepted as ship-with-assumption.
18. Builds pass on the Android + iOS device matrix defined in `ARCHITECTURE.md`.

---

## 10. Open questions & assumptions

### 10.1 Assumptions
| ID | Assumption |
|---|---|
| AS-1 | The three MVP boosters are **Extra Spark, Rewind, Slow-Mo** (Guided Line and Bomb Spark deferred). CONCEPT.md specifies "3 core boosters" without naming them; this selection is the proposed default pending PM sign-off. |
| AS-2 | "First N sessions" with no interstitials defaults to **N = 3**, tunable via Remote Config. |
| AS-3 | Sector star-gate thresholds and per-level par values are defined in `LEVEL_DESIGN.md`; this PRD treats them as authored data, not hard-coded constants. |
| AS-4 | Mid-tier reference devices and min SDK targets are defined in `ARCHITECTURE.md`; performance NFR targets are measured against that matrix. |
| AS-5 | A Supernova finale at level 60 ships in MVP (it is the sector-3 boundary); finales at 80 and 100 are Post-MVP. |
| AS-6 | Stardust earn paths in MVP are intentionally limited (achievements/events are mostly Post-MVP), so MVP stardust comes mainly via IAP and sparse grants; this is acceptable for v1.0. |
| AS-7 | Optional stardust collectibles appear on a subset of levels (designer's choice), not all 60. |
| AS-8 | Daily reward resets on a missed day by default (configurable); exact streak table lives in Remote Config / `MONETIZATION.md`. |

### 10.2 Open questions
| ID | Question | Owner | Needed by |
|---|---|---|---|
| OQ-1 | Exact star-rating formula weighting (sparks-used efficiency vs stardust) per sector — confirm with `LEVEL_DESIGN.md`. | Design | Level authoring |
| OQ-2 | Final interstitial cap parameters (frequency + cooldown + first-session count) — confirm with `MONETIZATION.md` and live-tuning plan. | Product/Monetization | Pre-soft-launch |
| OQ-3 | IAP price points and starter-pack contents — confirm with `MONETIZATION.md`. | Monetization | Store setup |
| OQ-4 | COPPA strategy: will the app declare a child-directed audience, a mixed audience with an age gate, or a 13+ audience? This determines ad SDK config. | Legal/Product | Consent implementation |
| OQ-5 | Account linking providers for MVP (Google + Apple confirmed? email?) and Apple's "Sign in with Apple" requirement implications. | Product/Eng | Auth implementation |
| OQ-6 | Should MVP ship a basic Achievements scaffold or fully defer to Post-MVP? CONCEPT lists achievements as a live feature but MVP scope omits them. | Product | Sprint planning |
| OQ-7 | Offline life-accrual cap (how much regen can bank while offline before requiring a server reconcile). | Eng/Product | Economy implementation |
| OQ-8 | Target initial download-size budget exact number and asset-streaming strategy. | Eng | Build setup |
| OQ-9 | FCM re-engagement campaign content/cadence for MVP vs Post-MVP. | Marketing/Product | Soft launch |

---

*End of PRD v1.0 (MVP). Canonical source: [`CONCEPT.md`](./CONCEPT.md).*
