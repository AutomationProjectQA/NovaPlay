# NovaPlay — Vision & Product Discovery (Sprint 0)

> **Sprint 0 deliverable.** This document captures the product discovery for NovaPlay.
> It is **derived from and subordinate to** [`CONCEPT.md`](./CONCEPT.md) — the canonical
> concept bible. Where this document expands on a topic (monetization, roadmap), the
> dedicated doc named below is authoritative for that detail.
> Status: **Draft v1.0** · Owner: Product

---

## 1. Vision Statement & Mission

### Vision
A galaxy has gone dark, and a single wandering spark can bring it back. **NovaPlay** is the
mobile puzzle that makes physics feel like poetry — calm, premium, and quietly clever — where
every "so close" pulls you into one more try and every solve ends in light.

### Mission
To deliver a **calm-but-clever cosmic physics puzzle** that respects the player's time and
intelligence: 60–180-second levels you can play one-handed, readable physics you can always
predict, and a free-to-play experience that is **value-positive and never pay-to-win**.

> **Tagline:** *"Light the constellations."*

### Strategic intent
- Own the intersection of **skill (trajectory/physics)** and **calm (lofi-space mood)** — a
  lane most physics puzzlers ignore in favor of frantic or cluttered designs.
- Win on **feel and polish** first, content breadth second.
- Build a sustainable, ethical F2P economy that scales from MVP (sectors 1–3) to the full
  100-level vision and beyond.

---

## 2. Market Context

> **Note on figures.** The numbers below are **reasonable industry estimates and stated
> assumptions for planning purposes**, not live-researched, source-cited market data. They are
> used to frame opportunity sizing and should be validated before any funding or GTM decision.

### Assumptions about the casual / puzzle mobile market
- **Puzzle is the largest mobile game genre by downloads** and one of the largest by share of
  players, with a broad, mass-market, ad-friendly audience.
- The genre skews toward **short-session, high-frequency play**, which fits NovaPlay's
  60–180-second levels and "≥ 3 sessions/day for engaged users" target.
- **Hybrid monetization (rewarded ads + interstitials + light IAP)** is the dominant and
  best-performing model for casual puzzle, which is exactly the model locked in `CONCEPT.md §9`.
- **CPIs are competitive** and rising; differentiation on **feel, theme, and polish** materially
  affects organic uplift and creative performance — reinforcing our "win on feel" thesis.
- Player tolerance for **intrusive ads is falling**; value-positive, opt-in rewarded design is
  both an ethical and a retention advantage.

### Why now
- **Lofi / "calm aesthetic"** content (lofi music, cozy games, minimalist design) has strong
  cultural momentum; a premium-feeling, relaxing space puzzler is on-trend.
- **Flutter + Flame** has matured enough to ship a 60 FPS 2D physics game cross-platform from a
  single codebase, lowering our build-and-maintain cost vs. native or a heavyweight engine.

### Market risks (summarized; full register in §8)
- The genre is **crowded and high-churn**; undifferentiated puzzlers fail to retain.
- **UA economics** can erode margins if D1/D7 retention falls below benchmark.

---

## 3. Target Market & Segments

**Primary audience (per `CONCEPT.md §10`):** casual mobile gamers **aged 18–45**, fans of
puzzle and "relaxing skill" games (Two Dots, Flow, Angry Birds-lite, ZigZag, Color Switch).
Broad, mass-market, ad-friendly.

| Segment | Description | What they want | How we serve them |
|---|---|---|---|
| **Calm Unwinders** | Adults decompressing in short breaks (commute, bed, queue). | Low-stress, beautiful, no time pressure. | Calm spectacle pillar, no real-time fail, lofi-space mood. |
| **Skill Seekers** | Players who enjoy mastering a mechanic and chasing 3-star efficiency. | Depth, mastery, "I got better." | Star ratings on efficiency, optional stardust, finales. |
| **Snackers / Streak-keepers** | High-frequency, low-duration players. | Daily reason to return, fast sessions. | Daily Challenge, login streak, lives cadence. |
| **Spenders (small minority)** | Willing to pay to remove ads or save time. | Convenience, cosmetics, no FOMO pressure. | Remove Ads + perks, cosmetic skins, never pay-to-win. |

Geographic focus at launch: **English-speaking markets (EN locale)**, with localization
scaffolding for expansion (`CONCEPT.md §11`).

---

## 4. User Personas

### Persona 1 — "Commuter Casey"
- **Age:** 29 · **Role:** Marketing coordinator · **Device:** Mid-tier Android
- **Behavior:** Plays in 5–10 minute bursts on the train, twice a day. Hates anything that
  needs sound on or two hands.
- **Motivations:** Decompress, feel a small win, "just one more."
- **Pain points:** Frantic games stress her out; intrusive mid-level ads make her quit; games
  that demand long sessions don't fit her life.
- **Why NovaPlay:** Portrait, one-handed, 60–180s levels, calm mood, instant retry. The "one
  more try" pillar is built for her commute.

### Persona 2 — "Perfectionist Priya"
- **Age:** 34 · **Role:** Software QA engineer · **Device:** Recent iPhone
- **Behavior:** Replays levels to 3-star them; tracks her own efficiency; finishes content.
- **Motivations:** Mastery, elegant solutions, completion.
- **Pain points:** Random/luck-based difficulty; pay-to-win walls; shallow games she exhausts
  in a day.
- **Why NovaPlay:** Deterministic, readable physics rewards skill; star ratings on sparks-used
  and stardust give a real mastery loop; finales ("Supernova") are puzzle set-pieces, not luck.

### Persona 3 — "Streak Sam"
- **Age:** 22 · **Role:** University student · **Device:** Budget Android
- **Behavior:** Logs in daily mainly for the streak and free rewards; plays a few levels, claims,
  leaves. Will watch a rewarded ad for value.
- **Motivations:** Don't break the streak, free stuff, light progression.
- **Pain points:** Aggressive monetization; energy systems that feel punishing; FOMO anxiety.
- **Why NovaPlay:** Daily Challenge + login streak + Lucky Wheel/chests give a daily hook;
  rewarded ads are opt-in and value-positive; lives regenerate fairly.

### Persona 4 — "Relaxing Robert"
- **Age:** 41 · **Role:** Operations manager, parent of two · **Device:** Mid-tier Android tablet & phone
- **Behavior:** Plays to wind down at night, sound on, no rush. Occasionally buys Remove Ads on
  games he sticks with.
- **Motivations:** Calm, aesthetic pleasure, a quiet sense of progress.
- **Pain points:** Loud, cluttered games; ad spam; complex rule stacks.
- **Why NovaPlay:** "Calm spectacle" and "elegant escalation" pillars — one new idea every few
  levels, joyful payoff on success. A prime Remove-Ads + cosmetics buyer.

---

## 5. Business Model & Monetization Summary

NovaPlay is **free-to-play with hybrid monetization** (`CONCEPT.md §9`). Headlines:

- **Rewarded ads (primary, opt-in, value-positive):** extra spark on fail, double coins, free
  life refill, free daily booster.
- **Interstitial ads:** between levels, frequency-capped (e.g. ≥ every 3rd level, with
  cooldown), never mid-level, never in the first sessions.
- **IAP:** Remove Ads (also grants perks), coin/stardust packs, booster bundles, cosmetic spark
  skins & backgrounds, optional starter pack.
- **No pay-to-win:** every level is solvable for free; IAP saves time and adds flair only.

> Full pricing, ad-placement rules, ARPDAU/conversion targets, and economy tuning live in
> [`MONETIZATION.md`](./MONETIZATION.md). That document is authoritative for monetization detail.

---

## 6. Value Proposition & Differentiation

### Value proposition
> **NovaPlay turns physics into a calm, beautiful ritual** — a relaxing skill puzzle where you
> can always predict the spark, failure is cheap and instantly retryable, and every solve ends
> in light.

### Differentiation pillars (from `CONCEPT.md §2`)
1. **Readable physics** — deterministic, predictable trajectories; skill over luck.
2. **One more try** — cheap, instant failure and retry; "so close," never "unfair."
3. **Elegant escalation** — one new idea per few levels; no wall of rules.
4. **Calm spectacle** — quiet board, joyful light/particle/sound payoff on success.

### What sets us apart in a crowded genre
- **Mood as a feature:** premium, minimal, "lofi space" — most physics puzzlers are loud and
  cluttered; we own calm.
- **Single cohesive fantasy:** you are the Nova reigniting a dark galaxy; theme, art, audio, and
  progression all reinforce it.
- **Ethical F2P:** value-positive rewarded ads and no pay-to-win build trust and retention.
- **Mastery loop with no luck:** efficiency-based stars + optional stardust give depth without
  randomness.

---

## 7. Success Metrics / KPIs

Mirrors and expands the headline metrics in `CONCEPT.md §13`.

### Retention (casual-puzzle benchmarks)
| Metric | Target | Notes |
|---|---|---|
| D1 retention | **≥ 40%** | Primary leading indicator of core-loop fit. |
| D7 retention | **≥ 18%** | Indicates daily features + early content land. |
| D30 retention | **≥ 7%** | Long-term hook; depends on content & live ops. |

### Engagement
| Metric | Target |
|---|---|
| Tutorial completion | **≥ 85%** |
| Average session length | **≥ 6 min** |
| Sessions/day (engaged users) | **≥ 3** |
| Daily Challenge participation | Track; grow over time |
| Star-3 rate (mastery loop) | Track per sector; tune difficulty |

### Technical quality
| Metric | Target |
|---|---|
| Crash-free sessions | **≥ 99.5%** |
| Frame rate | **60 FPS on mid-tier devices** |
| Cold start | Fast (target set in `ARCHITECTURE.md`) |

### Monetization (targets owned by `MONETIZATION.md`)
- Rewarded-ad **opt-in rate**, **ARPDAU**, **IAP conversion**, Remove-Ads attach rate.

---

## 8. Risk Register

Likelihood / Impact scale: **L / M / H**. Includes the headline risks from `CONCEPT.md §14`
plus additional product, technical, market, and ops risks.

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | **"Just another puzzle game"** — fails to stand out in a crowded genre. | H | H | Differentiate on feel, polish, calm/lofi-space theme, single cohesive fantasy; invest in art/audio/juice early; sharp ASO & creative testing. |
| R2 | **Physics feel** isn't deterministic/readable enough; trajectories feel random. | M | H | Heavy R&D in the Core Game Engine sprint (S8); deterministic, fixed-timestep simulation; trajectory preview; extensive playtesting against "readable physics" pillar. |
| R3 | **Ad fatigue** — too many/badly-placed ads tank retention. | M | H | Strict frequency caps (interstitial ≥ every 3rd level, cooldown, never mid-level, never first sessions); value-positive opt-in rewarded design; Remote Config tuning. |
| R4 | **Content cost** — 100 handcrafted levels is expensive and slow. | H | M | Build a **level-tooling/data pipeline early** (S10); ship MVP at sectors 1–3 (≥60 levels); data-driven levels so design ≠ code. |
| R5 | **Retention below benchmark** — D1/D7 misses targets, breaking UA economics. | M | H | Validate core loop in Beta (S20); instrument funnels (S17); tune onboarding, difficulty curve, and daily features via Remote Config. |
| R6 | **Difficulty curve mis-tuned** — too hard (churn) or too easy (boredom). | M | M | Smooth in-sector ramp + reset at boundaries (`CONCEPT.md §6`); analytics on level fail rates; Remote Config tuning; "stuck?" booster offers. |
| R7 | **Performance** — sub-60 FPS or jank on low/mid-tier Android. | M | M | 60 FPS target enforced in Performance sprint (S18); profiling on mid-tier devices; Flame render budget discipline. |
| R8 | **Flutter/Flame physics limitations** for the trajectory simulation. | L | M | Prototype the engine spike before committing scope; custom lightweight 2D physics tuned for readability over realism. |
| R9 | **Platform/store compliance** — ad SDK, IAP, privacy (ATT/consent), age rating. | M | M | Follow AdMob/IAP policies; implement consent/ATT; Store Assets & Release sprints (S21–22) own compliance checklists. |
| R10 | **Monetization too soft** — ethical model under-earns vs. cost. | M | M | Hybrid model with multiple rewarded surfaces; cosmetics + Remove Ads; A/B ad cadence and offers via Remote Config; targets tracked in `MONETIZATION.md`. |
| R11 | **Scope creep** — deferred features (events, leaderboards, sectors 4–5) pulled into MVP. | M | M | Hard MVP boundary (`CONCEPT.md §12`); roadmap discipline; post-MVP backlog. |
| R12 | **Live-ops dependency** — Firebase outage or misconfig affects cloud save/events. | L | M | Offline-first design (fully playable with no network); graceful degradation; Crashlytics + monitoring. |
| R13 | **Single-developer/small-team bus factor** & velocity risk across 23 sprints. | M | M | Documented architecture & data-driven content; prioritize MVP; defer non-essential systems. |

---

## 9. MVP Scope Summary

Mirrors `CONCEPT.md §12`. The MVP boundary is **hard** — deferred items are post-MVP.

### In v1.0 (MVP)
- Core **launch-and-light** mechanic with trajectory preview.
- **Sectors 1–3 (≥ 60 levels)** of the 100: Embers, Nebula, Void.
- **Star ratings** (efficiency / optional stardust).
- Screens: **home, level-select, settings, profile**.
- **Save/load + cloud sync**.
- **Coins + lives + 3 core boosters**.
- **Daily reward**.
- **AdMob rewarded + interstitial** ads.
- **Analytics + Crashlytics**.
- **Audio + haptics**.
- **English (EN)** locale.

### Deferred to post-MVP
- **Sectors 4–5 (levels 61–100)**.
- **Leaderboards**.
- **Events / seasonal content**.
- **Lucky Wheel / chests**.
- **Color-lock & switch mechanics**.
- **Additional locales**.
- **IAP cosmetics beyond Remove Ads**.

> Sprint-by-sprint delivery in [`ROADMAP.md`](./ROADMAP.md); exact acceptance criteria in
> [`PRD.md`](./PRD.md).
