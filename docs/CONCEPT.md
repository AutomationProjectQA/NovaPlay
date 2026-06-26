# NovaPlay — Concept Bible (Canonical)

> **This is the single source of truth.** Every other document in `docs/` derives
> from the locked decisions below. If a detail conflicts elsewhere, this file wins.
> Status: **Locked v1.0** · Last updated by Sprint 0.

---

## 1. One-liner

**NovaPlay** is a calm-but-clever **cosmic physics puzzle** for mobile: you launch a
spark of starlight across a constellation and bounce, curve, and ricochet it to
**light every dim star** before your sparks run out.

> Tagline: **"Light the constellations."**

## 2. Genre & pillars

- **Genre:** Casual physics / trajectory puzzle (skill + logic), single-player.
- **Session length:** 60–180 seconds per level. Pick-up-and-play.
- **Orientation:** Portrait, one-handed.
- **Mode:** Offline-first (fully playable with no network); cloud sync optional.
- **Tone:** Premium, minimal, "lofi space" — relaxing yet satisfyingly tricky.

**Design pillars (every decision serves these):**

1. **Readable physics** — the player can always predict roughly where the spark goes.
2. **One more try** — failure is cheap and instantly retryable; "so close" not "unfair."
3. **Elegant escalation** — one new idea per few levels; never a wall of rules.
4. **Calm spectacle** — quiet board, joyful payoff (light, particles, sound) on success.

## 3. Core fantasy

You are the **Nova** — a wandering spark of starlight reigniting a galaxy that has
gone dark. Each level is a **constellation**; clearing it relights one more piece of
the night sky and pushes back the dark.

## 4. Core mechanic (the 10-second pitch)

Each level is a 2D field holding several **dim stars**. You **drag to aim** a slingshot
(with a trajectory preview), **release to launch** the Nova spark. The spark travels
under simple physics and **lights any dim star it passes through**. **Light all stars to
clear the level.** You have a **limited number of sparks (shots)** per level.

- **Win:** all dim stars lit.
- **Lose:** out of sparks with stars still dim.
- **Restart / Undo:** instant restart; **Rewind** undoes the last shot (booster).

## 5. Field elements & mechanics (introduced gradually)

| Element | Behavior | Intro'd around |
|---|---|---|
| **Dim star** | Lights when the spark touches it. Win = all lit. | Level 1 |
| **Wall / asteroid** | Solid; spark bounces off (reflective). | Level 1 |
| **Bumper** | Bouncy pad; adds energy/speed to the bounce. | ~Level 8 |
| **Gravity well** | Curves the spark's path toward it. | ~Level 18 |
| **Black hole (sink)** | Swallows the spark (ends the shot) — a hazard to avoid. | ~Level 30 |
| **Portal / wormhole** | Teleports the spark to a paired exit, keeping momentum. | ~Level 40 |
| **Moving obstacle** | Asteroid/gate that drifts on a timed path. | ~Level 50 |
| **Color-locked star** | Only lights if the spark is the matching color. | ~Level 60 |
| **Multi-hit star** | Needs 2–3 touches to fully light. | ~Level 70 |
| **Switch / gate** | Hitting a switch opens a barrier elsewhere. | ~Level 80 |

**Boss / finale ("Supernova"):** every sector finale (levels 20, 40, 60, 80, 100) is a
larger set-piece — an unstable star requiring multiple precise hits while the field
shifts or hazards intensify. Not a real-time boss fight; a harder puzzle with theatrics.

## 6. Progression & structure

- **100 handcrafted levels**, grouped into **5 sectors × 20 levels**:
  1. **Embers** (1–20) — basics: aim, bounce, walls.
  2. **Nebula** (21–40) — bumpers, gravity wells.
  3. **Void** (41–60) — black holes, portals.
  4. **Pulsar** (61–80) — moving obstacles, color locks.
  5. **Singularity** (81–100) — multi-hit, switches, everything combined.
- **Sequential unlock**: clearing a level unlocks the next. Sectors gated by total stars.
- **Star rating per level (0–3):** based on **sparks used** (efficiency) and/or collecting
  optional **stardust** scattered on the board. 3 stars = mastery.
- **Difficulty curve:** smooth ramp inside each sector, small reset + new mechanic at each
  sector boundary. See `LEVEL_DESIGN.md`.

## 7. Economy & currencies

| Item | Type | Earned by | Spent on |
|---|---|---|---|
| **Coins** | Soft currency | Clearing levels, stars, daily rewards, rewarded ads | Boosters, lives refill, cosmetics |
| **Stardust** | Hard/premium currency | Sparingly from achievements/events; IAP | Premium boosters, exclusive skins, skip |
| **Lives (energy)** | Gate | Regenerate over time (e.g. 1 / 20 min, cap 5) | Spent on a failed attempt |
| **XP / Player Level** | Progression | Playing, clearing, missions | Unlocks cosmetics & profile flair |
| **Boosters** | Consumables | Coins, rewards, IAP bundles | Used in-level |

**Boosters / power-ups:** Guided Line (extended aim preview), Slow-Mo (slows the spark
mid-flight), Extra Spark (one more shot), Bomb Spark (clears nearby asteroids on impact),
Rewind (undo last shot). Pre-level loadout + in-level "stuck?" offers.

## 8. Live & retention features

- **Daily Challenge** — one special level per day; streak rewards.
- **Daily rewards / login streak**, **Lucky Wheel**, **Chests**.
- **Achievements, Missions (daily/weekly)**.
- **Events & seasonal content** — themed level packs, limited cosmetics.
- **Leaderboards** — by stars earned and/or event score (friends + global).

## 9. Monetization (free-to-play)

- **Rewarded ads** (opt-in, value-positive): extra spark on fail, double coins, free
  life refill, free daily booster. The primary, least-intrusive revenue driver.
- **Interstitial ads**: between levels, frequency-capped (e.g. ≥ every 3rd level, with
  cooldown), never mid-level, never on the first sessions.
- **IAP**: Remove Ads (also grants perks), coin/stardust packs, booster bundles,
  cosmetic spark skins & backgrounds, optional starter pack.
- **No pay-to-win**: IAP saves time/adds flair; every level is solvable for free.

See `MONETIZATION.md`.

## 10. Target audience

Casual mobile gamers **18–45**, puzzle & "relaxing skill game" fans (Two Dots, Flow,
Angry Birds-lite, ZigZag, Color Switch audiences). Broad, mass-market, ad-friendly.
Personas in `VISION.md`.

## 11. Platforms & technology (locked)

- **Engine/app:** **Flutter** (stable channel) + **Flame** for the 2D game loop/rendering.
- **State management:** **Riverpod**.
- **Navigation:** **GoRouter**.
- **DI:** **get_it** + **injectable**.
- **Models/serialization:** **freezed** + **json_serializable**.
- **Local persistence:** **Hive** (or Isar) for save/progress; **shared_preferences** for flags.
- **Backend:** **Firebase** — Auth (anonymous + optional link), Cloud Firestore (cloud save,
  leaderboards, events config), Remote Config (tuning/flags/A-B), Analytics (GA4),
  Crashlytics, Cloud Messaging (push), optional Cloud Functions.
- **Ads:** **AdMob** via `google_mobile_ads`. Mediation later.
- **IAP:** `in_app_purchase`.
- **Localization:** `easy_localization` (or Flutter intl). Launch locales: EN (+ scaffold for more).
- **Targets:** Android (Google Play) + iOS (App Store). Min SDK per `ARCHITECTURE.md`.
- **Performance target:** 60 FPS, fast cold start, low memory/battery.

## 12. MVP scope (what ships v1.0)

**In:** core launch-and-light mechanic; sectors 1–3 (≥ 60 levels) of the 100; star ratings;
home/level-select/settings/profile; save/load + cloud sync; coins + lives + 3 core boosters;
daily reward; AdMob rewarded + interstitial; analytics + Crashlytics; audio + haptics; EN.

**Deferred to post-MVP:** sectors 4–5 (levels 61–100), leaderboards, events/seasonal,
Lucky Wheel/chests, color-lock & switch mechanics, additional locales, IAP cosmetics
beyond Remove Ads.

See `ROADMAP.md` for the sprint-by-sprint plan and `PRD.md` for exact acceptance criteria.

## 13. Success metrics (headline)

- **D1 retention ≥ 40%**, **D7 ≥ 18%**, **D30 ≥ 7%** (casual puzzle benchmarks).
- **Tutorial completion ≥ 85%**; **average session ≥ 6 min**; **≥ 3 sessions/day** for engaged.
- **Crash-free sessions ≥ 99.5%**; **60 FPS on mid-tier devices**.
- Monetization: rewarded-ad opt-in rate, ARPDAU, IAP conversion — targets in `MONETIZATION.md`.

## 14. Key risks (headline)

- **"Just another puzzle game"** — differentiate via feel, polish, and the cosmic theme.
- **Physics feel** — must be deterministic and readable; heavy R&D in the engine sprint.
- **Ad fatigue** — strict frequency caps + value-positive rewarded design.
- **Content cost** — 100 handcrafted levels is real work; build a level tooling pipeline early.

Full register in `VISION.md`.
