# NovaPlay — UI/UX Guidelines (Sprint 3)

> Derived from `CONCEPT.md` (Locked v1.0). If anything here conflicts with the
> Concept Bible, the Concept Bible wins. This document defines the *experience*:
> information architecture, flows, wireframes, motion, accessibility, and voice.
> The concrete tokens & components live in `DESIGN_SYSTEM.md`.

**Theme:** premium minimal "lofi space" — calm-but-clever cosmic physics puzzle.
**Frame:** Portrait, one-handed, offline-first, 60 FPS.
**North star:** A quiet board, a joyful payoff. Every screen should feel like
drifting through a calm night sky and tapping exactly the one thing you meant to.

---

## 1. Information Architecture

The screen map as a hierarchy. Indentation = "reachable from / nested under".
`(modal)` = overlay sheet/dialog. `(overlay)` = full-screen but transient.

```
NovaPlay
├── Splash / Boot (overlay)            · logo ignition, preload, route decision
├── First-Run Onboarding (overlay)     · 3 calm slides + interactive tutorial L1
│
├── Home / Galaxy Map  ◀── default landing for returning players
│   ├── Sector nodes (Embers, Nebula, Void, Pulsar, Singularity)
│   │   └── Level Select (sector view)
│   │       └── Level node → Pre-Level Loadout (modal)
│   │           └── Gameplay
│   │               ├── Pause (modal)
│   │               ├── Win (overlay)
│   │               │   ├── → Next level (Gameplay)
│   │               │   └── → Map / Level select
│   │               ├── Lose (overlay)
│   │               │   ├── → Retry (Gameplay)
│   │               │   ├── → Rewarded ad: +1 Spark (continue)
│   │               │   └── → Map / Level select
│   │               └── Interstitial ad (overlay, frequency-capped)
│   │
│   ├── Top HUD bar
│   │   ├── Coins badge        → Shop (Coins tab)
│   │   ├── Stardust badge     → Shop (Stardust tab)
│   │   ├── Lives pill + timer → Lives refill sheet (modal)
│   │   └── Settings (gear)    → Settings
│   │
│   └── Bottom navigation
│       ├── Home (Galaxy Map)
│       ├── Daily          → Daily Reward (modal) + Daily Challenge level
│       ├── Shop           → Shop
│       └── Profile        → Profile
│
├── Daily Reward (modal)               · streak ladder, claim, "play daily" CTA
├── Shop                               · tabs: Boosters · Coins · Stardust · Cosmetics · Remove Ads
│   └── Purchase confirm (modal) → IAP system sheet
├── Profile                           · player level/XP, stars, achievements, stats, cloud-sync
│   └── Achievement detail (modal)
└── Settings                          · audio, haptics, motion, language, account, legal, restore
```

**Hierarchy rules**

- **One primary destination per screen.** Map → play. Don't bury "Play" under
  taps. The whole map exists to launch the next level.
- **Currencies and Settings are always reachable** from the persistent top HUD on
  hub screens (Home, Shop, Profile, Daily). They are *not* shown during gameplay.
- **Gameplay is a leaf with no bottom nav** — it is full-immersion. The only exits
  are Pause and the result overlays.
- **Bottom nav has exactly 4 tabs** (Home, Daily, Shop, Profile). No more.
  Daily shows a badge dot when an unclaimed reward or fresh challenge is available.

---

## 2. Core User Flows

Each step lists: **trigger → system → screen**. Happy path first, then branches.

### 2.1 First-Run Onboarding (cold install)

1. App launches → **Splash**: logo "ignites", assets + save preload (target < 2s).
2. No save found → route to **Onboarding**.
3. **Slide 1** ("You are the Nova"): one line of copy, animated spark. Swipe / "Next".
4. **Slide 2** ("Drag to aim, release to launch"): shows a ghosted finger drag with
   trajectory preview. Swipe / "Next".
5. **Slide 3** ("Light every star before your sparks run out"): swipe / "Begin".
6. → **Interactive Tutorial = Level 1**, with coach marks:
   - Coach mark 1: pulsing hand over slingshot → "Drag back to aim."
   - On drag: live trajectory preview appears. Coach mark 2: "Release to launch."
   - On launch + first star lit: micro-celebration. Coach mark 3: "Light them all."
   - On win: standard **Win** overlay, but tutorial-flavored ("You're a natural").
7. Save created. Subsequent launches skip onboarding → land on **Home / Map**.
   - *Skip:* a low-emphasis "Skip" (top-right) on slides jumps to Level 1 (tutorial
     coach marks still play — never skip the *interactive* teaching of the core verb).
   - Target: tutorial completion ≥ 85%.

### 2.2 Play a Level → Win → Next

1. **Map / Level Select** → tap an unlocked **Level node**.
2. **Pre-Level Loadout (modal)**: level number, best stars, optional booster
   loadout chips, "Play" CTA. (Auto-skippable via setting after first use.)
3. **Lives check:** if Lives > 0, deduct nothing yet (life is consumed only on a
   *failed* attempt per `CONCEPT.md`). If Lives == 0 → **Lives refill sheet** (wait /
   rewarded ad / coins / IAP) before play.
4. → **Gameplay**. Player drags to aim (trajectory preview), releases to launch.
5. Spark lights stars; HUD spark counter decrements per shot.
6. **All stars lit** → freeze board → **Win overlay**:
   - Star rating animates in (0–3 based on sparks used / stardust collected).
   - Coin reward counts up; XP bar ticks.
   - CTAs: **Next** (primary), **Replay** (ghost), **Map** (ghost).
   - Optional **rewarded "Double coins"** chip.
7. **Next** → next level unlocks → **Gameplay** (skip loadout if setting on).
   - Every Nth level boundary → **Interstitial** (frequency-capped, with cooldown,
     never mid-level, never first sessions).

### 2.3 Play → Lose → Retry / Rewarded Continue

1. In **Gameplay**, last spark launched, stars still dim → **Lose overlay**.
2. Lose is gentle — "So close." Show stars remaining, not a harsh "FAIL".
3. A **Life is consumed** for the failed attempt (HUD lives pill updates).
4. CTAs:
   - **+1 Spark (Watch ad)** — rewarded, value-positive; returns to the *same board
     state* with one extra spark. Primary if a rewarded ad is available & sensible.
   - **Retry** — restart the level fresh (subject to Lives).
   - **Map** — leave.
5. If Lives hit 0 after the loss → on next play attempt, **Lives refill sheet**.

### 2.4 Level Select & Sector Map

1. From **Home / Galaxy Map**, sectors are large nodes along a winding constellation
   path (Embers → Singularity). Locked sectors are dimmed with a star-gate cost.
2. Tap a sector → **Level Select (sector view)**: a constellation of 20 level nodes
   connected by a faint dotted path. Each node shows its number + earned stars.
3. Node states: **locked** (dim, padlock), **unlocked/next** (glowing, pulse),
   **cleared** (lit, 0–3 stars). Current/next level auto-centers.
4. Tap unlocked node → **Pre-Level Loadout** (§2.2).
5. Sector finale (levels 20/40/60/80/100) node is visually larger ("Supernova").
6. Sector gates: a locked sector shows "Collect N stars to unlock." Tapping a locked
   sector shows the requirement, never a dead tap.

### 2.5 Daily Reward Claim

1. Bottom nav **Daily** (badge dot if unclaimed) → **Daily Reward (modal)**.
2. Shows a **7-day streak ladder**; today's tier is highlighted and claimable.
3. Tap **Claim** → coins/booster fly to the HUD badge; tier marks complete; ladder
   advances. Missed-day rule per economy (streak reset/soft-reset).
4. Secondary CTA: **Play Daily Challenge** → loads today's special level (Gameplay).
5. Already claimed today → ladder shows next claim countdown; **Claim** is disabled
   with "Come back tomorrow."

### 2.6 Shop Purchase

1. Tap a **currency badge** (or bottom nav **Shop**) → **Shop**, deep-linked to tab.
2. Tabs: **Boosters · Coins · Stardust · Cosmetics · Remove Ads**.
3. Tap a pack → **Purchase confirm (modal)**: item, contents, price.
   - Soft purchase (coins for boosters): confirm → deduct → grant → toast.
   - Insufficient funds → inline "Get more coins?" routing to Coins tab.
   - IAP (real money): confirm → native store sheet → on success, grant + receipt
     toast; on cancel/fail, return quietly (no scary error unless truly failed).
4. **Remove Ads** purchase also grants perks; on success, ad surfaces disappear app-wide.
5. **No pay-to-win** is reinforced in copy: IAP saves time/adds flair.

### 2.7 Settings

1. Top HUD **gear** (or Profile → Settings) → **Settings**.
2. Grouped sections: **Audio** (music, SFX sliders), **Haptics** (toggle),
   **Motion** (Reduced Motion toggle), **Language**, **Account** (sign in / cloud
   sync status), **Legal** (privacy, terms), **Restore Purchases**, **Reset tutorial**.
3. Each control applies instantly (no "Save" button); a toast confirms destructive
   actions (e.g., sign-out). Changes persist locally immediately.

---

## 3. Wireframe Descriptions

Portrait, ~9:19.5. Regions: **status zone (top)**, **content (middle)**,
**action zone (bottom, thumb-reachable)**. Primary actions live in the bottom third.

### 3.1 Splash / Boot

```
┌───────────────────────────┐
│                           │
│                           │
│            ·  ✦  ·        │   faint starfield, parallax-still
│                           │
│         N O V A P L A Y    │   wordmark fades up
│           (spark igniting) │   single spark draws the dot of the "i"
│                           │
│        Light the          │   tagline, low opacity
│        constellations.    │
│                           │
│        [ ···· loading ]    │   subtle indeterminate shimmer, no % 
└───────────────────────────┘
```
- No buttons. Auto-advances when preload completes (min display ~800ms to avoid flash).

### 3.2 Home / Galaxy Map

```
┌───────────────────────────┐
│ ⚙   🪙 1,240  ✦ 12  ❤×4 19:58│  top HUD: settings · coins · stardust · lives+timer
├───────────────────────────┤
│        ✶ Singularity 🔒    │  locked sector, dim, "Collect 220★"
│           \                │
│            ✷ Pulsar 🔒      │  winding constellation path
│           /                │
│        ✸ Void 🔒            │
│         \                  │
│          ✺ Nebula  ●       │  in-progress, progress ring
│         /                  │
│   ▶  ✹ Embers  ★★★ done    │  current focus auto-centered, "Continue" glow
│                            │
├───────────────────────────┤
│  🏠 Home  ◐ Daily•  🛍 Shop  👤 │  bottom nav (Daily badge dot)
└───────────────────────────┘
```
- **Continue** affordance: a glowing "▶ Continue Lv N" pill near the player's
  current node — the single most prominent action.
- Vertical scroll reveals sectors; the path is the spine.

### 3.3 Level Select (within a sector)

```
┌───────────────────────────┐
│ ←  EMBERS            ★ 41/60│  back · sector name · stars in sector
├───────────────────────────┤
│      (1)──(2)──(3)         │  dotted constellation path
│       ★★★  ★★☆   ★★★        │  stars under each cleared node
│              \             │
│        (4)──(5)            │
│        ★☆☆   ◉next         │  (5) = next, glowing pulse
│         \                  │
│    🔒(6)  🔒(7) … 🔒        │  locked = padlock, dim
│              …             │
│        ✦ (20) SUPERNOVA    │  larger finale node
│                            │
├───────────────────────────┤
│         scroll for more ↓  │
└───────────────────────────┘
```
- Tapping a node opens the **Pre-Level Loadout** modal (number, best stars,
  booster chips, **Play**).

### 3.4 Gameplay HUD

```
┌───────────────────────────┐
│ ❚❚      Lv 12      ✦✦✦○○   │  pause · level · spark counter (remaining/used)
├───────────────────────────┤
│                            │
│        ☆        ★          │  board: dim stars (☆) + lit (★)
│           ▦                │  walls/asteroids
│     ☆          ⦿           │  gravity well later sectors
│                            │
│              ◐ Nova        │  spark at slingshot, faint aim ring
│             ╱              │  trajectory preview (dotted) on drag
│   ⟜ slingshot anchor       │
├───────────────────────────┤
│  ⟲ Rewind   ◷ Slow   ⊕ Spark│  in-level booster tray (only owned), bottom
└───────────────────────────┘
```
- **No currency HUD during play.** Minimal chrome. Spark counter is the only
  persistent status. Board occupies the dominant central region.
- Booster tray sits in the thumb zone; tapping a booster arms it (clear armed state).
- Trajectory preview appears only while dragging.

### 3.5 Pause (modal)

```
        ┌───────────────────┐
        │       Paused      │
        │                   │
        │   ▶  Resume       │  primary
        │   ⟲  Restart      │  secondary
        │   ♪  Audio  [on]  │  quick toggles
        │   ✦  Haptics [on] │
        │   🏠  Quit to Map  │  ghost / confirm if mid-progress
        └───────────────────┘
   (board dimmed + blurred behind)
```

### 3.6 Win (overlay)

```
┌───────────────────────────┐
│        Constellation lit!  │  warm headline
│                            │
│        ★   ★   ☆           │  stars pop in sequentially w/ chime
│                            │
│      +120 🪙   +40 XP       │  rewards count up
│      [▓▓▓▓▓░░] Lv 7        │  XP bar tick
│                            │
│   ◇ Watch ad → Double coins│  optional rewarded chip
│                            │
│   ┌──────────┐ ┌────┐ ┌───┐│
│   │  ▶ Next  │ │Replay│ │Map││  primary · ghost · ghost
│   └──────────┘ └────┘ └───┘│
└───────────────────────────┘
```

### 3.7 Lose (overlay)

```
┌───────────────────────────┐
│         So close.          │  gentle, never "FAIL"
│                            │
│    2 stars still dim ☆ ☆   │  shows what's left, encouraging
│                            │
│   ┌──────────────────────┐ │
│   │ ◇ Watch ad → +1 Spark │ │  rewarded continue, primary
│   └──────────────────────┘ │
│   ┌──────────┐  ┌────────┐ │
│   │ ⟲ Retry  │  │  Map   │ │  secondary · ghost
│   └──────────┘  └────────┘ │
│    ❤ × 3 lives left        │  life consumed, shown calmly
└───────────────────────────┘
```

### 3.8 Settings

```
┌───────────────────────────┐
│ ←  Settings                │
├───────────────────────────┤
│ AUDIO                      │
│   Music     ──●──── 70%    │  slider
│   SFX       ────●── 85%    │
│ FEEL                       │
│   Haptics            [on]  │  toggle
│   Reduced Motion     [off] │  toggle
│ GENERAL                    │
│   Language        English ›│
│   Account     Signed in  › │  cloud-sync status
│ ABOUT                      │
│   Restore Purchases       ›│
│   Privacy · Terms         ›│
│   Reset Tutorial          ›│
│   Version 1.0.0 (build 12) │
└───────────────────────────┘
```

### 3.9 Profile

```
┌───────────────────────────┐
│ ←  Profile          ⚙      │
├───────────────────────────┤
│      (◐ avatar / skin)     │
│      Stardrifter           │  display name
│      Level 7  [▓▓▓▓░░] XP  │
│                            │
│   ⭐ 124 stars   🌟 41/60 lv │  headline stats grid
│   🎯 best streak 9          │
├───────────────────────────┤
│  ACHIEVEMENTS              │
│   [🏆][🏆][🔒][🔒][🔒] …    │  badge grid → detail modal
├───────────────────────────┤
│  ☁ Cloud sync: on ·  just now│
└───────────────────────────┘
```

### 3.10 Shop

```
┌───────────────────────────┐
│ ←  Shop      🪙1,240 ✦12    │
├───────────────────────────┤
│ [Boosters][Coins][Stardust][Cosmetics][No Ads]│  tab strip (scrollable)
├───────────────────────────┤
│  ┌──────┐  ┌──────┐        │  pack cards grid
│  │⟲ Rewind│  │⊕ Spark│      │
│  │ x5 🪙90│  │ x5 🪙120│     │
│  └──────┘  └──────┘        │
│  ┌──────┐  ┌──────┐        │
│  │◷ Slow │  │ Bundle│ BEST │  "best value" ribbon
│  │x3 🪙80│  │ ✦ 4.99│      │
│  └──────┘  └──────┘        │
├───────────────────────────┤
│  Every level is solvable for free. │  trust line
└───────────────────────────┘
```

### 3.11 Daily Reward (modal)

```
        ┌────────────────────┐
        │   Daily Reward      │
        │   Day 4 streak 🔥    │
        │ ┌──┬──┬──┬──┬──┬──┬──┐│
        │ │✓ │✓ │✓ │◉ │  │  │🎁││  ladder, ◉ = claimable today
        │ │50│60│70│90│..│..│★ ││
        │ └──┴──┴──┴──┴──┴──┴──┘│
        │                     │
        │   [   Claim 90 🪙   ] │  primary
        │   Play Daily Challenge›│ secondary
        └────────────────────┘
```

---

## 4. Visual Style Direction

**Mood:** Calm, premium, quietly luminous. A planetarium at 1 a.m. — dark, soft,
deep, with a few points of warm light you actually look at. Lofi space:
unhurried, analog-warm glow over crisp vector clarity.

**References (in words):**

- The *quiet, generous negative space* of Two Dots / Alto's Odyssey menus.
- The *deep navy-to-violet gradients* of a clear night sky away from city light.
- The *soft bloom* of distant stars and nebulae — never neon, never harsh.
- The *tactile, satisfying "click"* feel of a well-made physical puzzle.

**Do**

- Lead with darkness; let light be the rare, meaningful element.
- Use one warm accent (nova gold/amber) as the hero — it = the player's spark.
- Keep boards uncluttered; readable physics demands a calm field.
- Use soft glows and subtle gradients for depth, not heavy borders.
- Give success a *spectacle* (light bloom, particles) — that's the payoff pillar.
- Respect the thumb zone: weight all primary actions to the bottom third.

**Don't**

- No neon cyberpunk, no harsh saturated rainbows, no busy backgrounds.
- No hard pure-white (#FFFFFF) fills on dark — use a soft off-white for text.
- No heavy drop shadows or skeuomorphic chrome — keep it minimal.
- No more than ~2 accent hues visible on a single screen.
- Don't decorate the gameplay board; decoration must never read as a game element.
- Don't punish failure visually — losing stays calm and inviting.

---

## 5. Motion & Animation Guidelines

Motion serves three jobs only: **orient** (transitions tell you where you went),
**confirm** (taps and rewards acknowledge you), **delight** (the win payoff). If a
motion does none of these, cut it.

### 5.1 Duration & easing reference

| Motion | Duration | Easing | Notes |
|---|---|---|---|
| Micro feedback (tap, toggle) | 80–120 ms | `easeOut` | Instant-feeling. |
| Standard transition (screen, modal in) | 220–300 ms | `easeInOut` / emphasized | Slide+fade. |
| Modal/sheet dismiss | 180–240 ms | `easeIn` | Slightly faster out than in. |
| Reward count-up (coins/XP) | 600–900 ms | `easeOut` | Tied to a soft chime. |
| Star pop (Win) | 3 × 180 ms | `easeOutBack` | Staggered ~120 ms apart. |
| Win light bloom / particles | 700–1000 ms | bespoke | The one allowed spectacle. |
| Level node unlock pulse | 1.4 s loop | `easeInOut` | Gentle breathing, not flashing. |
| Trajectory preview | real-time | none | Tracks finger 1:1, no lag. |
| Spark flight | physics-driven | n/a | Deterministic; never eased artificially. |

### 5.2 Restraint rules

- **Default to no animation.** Animate only the element that changed.
- **One spectacle per moment** — the Win bloom. Everywhere else, stay quiet.
- **Never block input** on decorative animation; results overlays must be skippable
  with a tap (tap-to-skip the count-up jumps to final values).
- **Loops breathe, never blink** — pulsing ≤ ~0.7 Hz, low amplitude.
- **Respect Reduced Motion** (see §6): cross-fades replace slides; particle/bloom
  reduced to a simple fade; loops become static glows.
- **Gameplay physics is never decorated** — the spark and trajectory must read as
  pure cause-and-effect (Pillar: readable physics).

---

## 6. Accessibility

Baseline: WCAG 2.1 AA intent, adapted for a game.

| Area | Standard |
|---|---|
| **Text contrast** | Body/UI text ≥ 4.5:1 against its surface; large text (≥ 18.66px bold / 24px) ≥ 3:1. Off-white on deep navy chosen to clear this. |
| **Non-text contrast** | Interactive borders, icons, focus/armed states ≥ 3:1. |
| **Color independence** | Never rely on color alone. Star rating = filled vs. outline *shape*; locked = padlock *icon*; sector identity = icon + label, not just hue. |
| **Color-blind safety** | Sector accents chosen to remain distinguishable in deuteranopia/protanopia (vary lightness + hue, not red/green pairs). Color-locked stars (post-MVP) carry a *symbol/pattern* per color, not color only. |
| **Text scaling** | Respect OS text scale up to 130%; layouts reflow, no clipping (see §8). Min body size 14sp, prefer 16sp. |
| **Reduced motion** | OS "Reduce Motion" + in-app toggle. Disables parallax, bloom→fade, loops→static. (§5.2) |
| **Haptics** | Meaningful, optional, and toggleable: light tick on launch, success buzz on star lit, soft thud on wall bounce. Never on every frame. Off = silent. |
| **Tap targets** | Every interactive control ≥ 48×48 dp hit area, even if the glyph is smaller. Min 8 dp spacing between adjacent targets. |
| **Audio cues** | Distinct, non-overlapping SFX for: launch, star lit, bounce, win, lose, out-of-sparks. Audio is *redundant* with visuals, never required to play (game is fully playable muted). |
| **One-handed reach** | Primary actions in the bottom third; nothing critical in the top corners except status. |

---

## 7. UX Writing / Tone

**Voice:** a calm, encouraging companion in the dark. Warm, brief, a little poetic
about light and stars — never cute-to-a-fault, never corporate, never harsh.

**Principles**

- **Brief.** Buttons are 1–2 words ("Next", "Watch ad", "Claim"). Headlines ≤ 4 words.
- **Encouraging on failure.** "So close." / "One more try?" — never "FAIL" / "You lost".
- **Thematic, lightly.** "Light the constellation", "Relight the sky" — sprinkle, don't drown.
- **Honest about money.** "Every level is solvable for free." No dark patterns, no fake
  urgency, no disguised ads. Rewarded ads are clearly opt-in and labeled with ◇/▷.
- **Plain over clever** when there's any risk of confusion (e.g., Settings labels).

**Examples**

| Context | Yes | No |
|---|---|---|
| Win | "Constellation lit!" | "LEVEL COMPLETE!!!" |
| Lose | "So close. One more try?" | "GAME OVER" |
| Locked sector | "Collect 220 stars to enter." | "LOCKED" |
| Out of lives | "Stars refill soon, or top up." | "NO LIVES! BUY NOW!" |
| Rewarded ad | "Watch a short ad for +1 spark" | "FREE SPARK!!!" |

---

## 8. Localization Readiness

Launch locale EN, with scaffold for more (`easy_localization` / intl).

- **Externalize all strings** — no hard-coded UI text; key everything from day one.
- **Plan for ~30–35% text expansion** (DE/FR/RU). Buttons and labels must not be
  fixed-width to their EN text; use min-width + wrap/auto-size, allow 2 lines on
  result-screen CTAs before truncating.
- **No text baked into images** — icons are glyphs; words stay in the string layer.
- **Numbers, dates, currencies** via locale formatters (coin counts, timers, IAP
  prices come from the store locale).
- **Pluralization** through ICU plural rules ("1 star" / "2 stars" / "0 stars").
- **RTL future-proofing:** build layouts with `start`/`end` (directional) padding and
  alignment, never hard `left`/`right`; mirror nav arrows, progress paths, and the
  galaxy-map spine under RTL; keep the *spark/aim* mechanic LTR-neutral (physics, not text).
- **Font coverage:** chosen type pairing (see `DESIGN_SYSTEM.md`) must include Latin
  Extended; verify diacritics; plan fallback fonts for future non-Latin scripts.
- **Avoid concatenation** — never build sentences from fragments; use full templated
  strings with named placeholders (`"Collect {count} stars"`).
```
