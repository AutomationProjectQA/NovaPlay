# NovaPlay — Game Design Document (GDD)

> **Sprint 2 deliverable.** Derives from `CONCEPT.md` (Locked v1.0), the single
> source of truth. Where this document adds concrete numbers, those numbers are
> tuning targets and are expected to be retuned via Remote Config (see
> `LEVEL_DESIGN.md` § Difficulty balancing). The *mechanics* defined here are
> canonical and must not drift from `CONCEPT.md`.
>
> Status: **Draft for review** · Owner: Game Design · Last updated: Sprint 2.

---

## 1. Design pillars

These are lifted verbatim from `CONCEPT.md` § 2 and are the lens for every
decision below. If a feature does not clearly serve one of these, it is cut.

1. **Readable physics** — the player can always predict *roughly* where the
   spark goes. No hidden randomness in flight; deterministic simulation; a
   trajectory preview that does not lie.
2. **One more try** — failure is cheap and instantly retryable. Restart is one
   tap, costs no animation, and never punishes with friction. The emotional
   note on loss is "so close," never "that was unfair."
3. **Elegant escalation** — one new idea per few levels; never a wall of rules.
   New mechanics are taught by level design, not text. (See § 6, § 9.)
4. **Calm spectacle** — a quiet, near-silent board; a joyful, loud payoff when
   a star lights and when a level clears. Restraint makes the payoff land.

**Anti-pillars (what NovaPlay is deliberately not):** twitch/reflex timing
challenges, real-time boss fights, energy-system rage-bait, RNG-gated outcomes,
read-a-wall-of-tutorial-text onboarding, pay-to-win.

---

## 2. Core gameplay loop

### 2.1 Moment-to-moment loop (within a single shot, ~3–8 s)

```
  TOUCH DOWN on board
        │
        ▼
  DRAG  ──► aim vector forms (slingshot pulls back opposite the drag)
        │   power = clamp(drag length); trajectory preview updates live
        ▼
  RELEASE ──► Nova spark launches along the aim vector at power-scaled speed
        │
        ▼
  FLIGHT (deterministic physics tick @ fixed dt)
        │   • reflects off walls/asteroids
        │   • gains speed from bumpers
        │   • curves through gravity wells
        │   • teleports through portals
        │   • LIGHTS any dim star it overlaps
        ▼
  SHOT ENDS when: spark leaves play / enters black hole / speed decays below
        │         threshold / a hard time cap (8 s) is reached
        ▼
  RESOLUTION ──► newly-lit stars stay lit; stardust collected stays collected;
                 spark budget decremented; check win / lose / continue
```

The loop is **strictly turn-based**: the player only ever controls aim and
release. Once launched, the player watches; they cannot steer the spark (except
via the Slow-Mo booster, which only changes *time*, not direction). This is the
core of "readable physics" — outcomes are a pure function of the launch vector
and the static/scripted board.

### 2.2 Session loop (one play session, ~6–15 min)

```
  HOME ──► tap Play ──► LEVEL SELECT (current sector)
        │
        ▼
  Spend 1 LIFE ──► enter LEVEL
        │
        ▼
  (optional) PRE-LEVEL LOADOUT: equip up to 3 boosters
        │
        ▼
  PLAY LEVEL  ──► shot → shot → shot …  (see 2.1)
        │
        ├─ WIN  ──► star tally (0–3) ──► coins/XP awarded ──► relight VFX
        │            │
        │            ├─ next level unlocked
        │            └─ (every ~3rd level) interstitial ad, frequency-capped
        │
        └─ LOSE ──► "out of sparks" ──► offer: rewarded-ad Extra Spark? / Retry
                     │
                     └─ Retry costs another life
        │
        ▼
  Continue to next level  OR  back to HOME (lives depleted / done)
```

### 2.3 Meta loop (across days/weeks)

```
  Clear levels ──► earn Coins + Stars + XP
        │
        ├─ Stars gate Sector unlocks (total-stars thresholds)
        ├─ Coins buy boosters / lives refill / cosmetics
        ├─ XP raises Player Level ──► cosmetic unlocks & flair
        │
        ▼
  Daily hooks: Daily Challenge (streak), Daily Reward, Lucky Wheel, Chests,
               Missions (daily/weekly), Events/seasonal packs, Leaderboards
        │
        ▼
  Return tomorrow ──► lives regenerated, daily reset, streak continues
```

The meta loop is the retention engine; it is intentionally **off the critical
path** so the core puzzle stands alone offline. See § 10.

---

## 3. Core mechanics in detail

### 3.1 Aiming (drag vector, power, trajectory preview)

- **Input model:** the player touches anywhere on the board and drags. The
  slingshot is anchored at the **launch node** (the Nova's current position,
  usually a fixed launcher at the bottom-center of the field). Aiming uses a
  **pull-back metaphor**, like Angry Birds: the launch direction is **opposite**
  the drag vector (drag down-left → launch up-right). This is the most intuitive
  and one-handed-friendly scheme for portrait.
- **Aim vector:** `aimDir = normalize(launchNode - touchPoint)`.
- **Power:** `power = clamp(distance(launchNode, touchPoint) / MAX_PULL, 0, 1)`.
  - `MAX_PULL` ≈ 35% of board height. Beyond it, power saturates at 1.0 and the
    slingshot band visibly stretches taut (no more gain) so the player learns
    the ceiling.
  - Launch speed: `speed = MIN_SPEED + power * (MAX_SPEED - MIN_SPEED)`.
    Targets: `MIN_SPEED` ≈ 6 board-units/s, `MAX_SPEED` ≈ 22 board-units/s
    (board is 100 units wide; see `LEVEL_DESIGN.md` coordinate system).
- **Trajectory preview:** a dotted/comet-dot prediction rendered by running the
  **same deterministic simulation** forward for a limited number of bounces.
  - Default preview: shows the path up to **2 reflections** (≈ first ~1.2 s of
    flight), then fades to dust. This keeps early levels honest while preserving
    challenge in later ones (you cannot pre-see a 6-bounce solution for free).
  - **Guided Line booster** extends the preview to **5 reflections** and through
    the first gravity-well curve.
  - The preview **must use the identical physics code** as live flight — never a
    separate approximation. Readability pillar depends on the preview not lying.
  - The preview does **not** show: black-hole capture beyond the first segment,
    portal exits beyond one hop (a "→" hint icon appears at the portal mouth),
    or moving-obstacle future positions (it previews against their *current*
    pose only, with a subtle shimmer to signal "this may move").
- **Aim assist (accessibility, optional toggle):** a fine-tune mode where, while
  dragging, the lower thumb-zone acts as a vernier (small finger moves = small
  angle changes). Off by default; surfaced in Settings.

### 3.2 Launching

- On **release**, the spark spawns at `launchNode` with velocity
  `aimDir * speed`. The slingshot band snaps with a haptic tick and a soft
  "thwip."
- Exactly **one spark is consumed** per launch (decrement budget on release, not
  on resolution — so the UI counter updates instantly and feels honest).
- The player cannot launch again until the current shot **resolves**
  (§ 3.6). This enforces the turn-based readability.
- **Mis-fire guard:** a drag shorter than `MIN_PULL` (≈ 4% of board height) on
  release **cancels** the shot (no spark consumed). Prevents accidental taps
  from wasting a spark — directly serves "one more try."

### 3.3 Spark physics (deterministic, readable)

NovaPlay's physics is a **custom 2D point-particle simulation** running on
Flame's fixed-timestep loop. We do **not** use a general rigid-body engine
(Box2D/Forge2D) for flight — full rigid-body sims are overkill, harder to make
perfectly deterministic across devices, and harder to keep readable. A bespoke
solver gives us exact control.

**Determinism rules (non-negotiable):**
- Fixed timestep `dt = 1/120 s`, accumulator-driven, decoupled from render FPS.
- All math in `double`; no per-frame RNG anywhere in flight.
- Collision resolved by **swept** circle-vs-segment tests (continuous collision
  detection) so a fast spark never tunnels through a thin wall — critical for
  readability and for the preview matching reality.
- Given the same level + same launch vector, the outcome is **bit-stable** on a
  given platform and visually identical across platforms.

**The spark itself:**
- Modeled as a **circle** of radius `r ≈ 1.2` board-units (generous, so
  "near miss" reads as a hit-or-clear-miss, never a pixel lottery).
- Carries a **velocity** vector and a **color** (default warm-white; matters
  only for color-locked stars, Sector 4+).

**Reflection off walls/asteroids:**
- Perfectly **elastic** reflection: `v' = v - 2 (v·n) n`, where `n` is the wall
  surface normal at the contact point. Speed is **preserved** on a wall bounce.
- Walls are defined as line segments / convex polygons; corners use the nearer
  edge's normal (with a tiny epsilon to avoid jitter at exact corners).

**Energy, friction, decay — the decision:**
- **Decision: NO friction / NO drag during normal flight. Speed is conserved**
  except where an element explicitly changes it (bumpers add, gravity wells
  trade speed for direction, black holes terminate).
- **Justification:**
  1. *Readability.* A constant-speed spark on straight segments is trivially
     predictable; the eye extrapolates a straight line perfectly. Adding drag
     makes the path a hard-to-eyeball curve and breaks the dotted-preview
     intuition.
  2. *Determinism & simplicity.* No decay constant to tune per device; the sim
     is a clean billiard model.
  3. *It bounds shot length cleanly.* Because there is no decay, we end shots by
     explicit rules (leaves play / black hole / time cap), which are easy to
     communicate, rather than "it slowly petered out somewhere off-screen."
- **The one exception — terminal decay as a safety net:** to guarantee every
  shot ends, if a spark is somehow still bouncing at the **8 s hard time cap**
  (extremely rare; e.g., trapped between two parallel walls), it ends. Visually
  we play a gentle "fizzle" so it reads as intentional, not a glitch. We do
  **not** rely on gradual friction to achieve this — the cap is the guarantee.
- **Maximum bounce count** is **not** capped by rule (capping mid-air would be
  unreadable); the time cap is the only flight limiter.

**Gravity (global down-force)?**
- **Decision: NO global gravity.** The field is "deep space." Curvature comes
  *only* from gravity-well elements (§ 4.4), which are local and clearly
  telegraphed by a visible swirl. A global down-force would make every level a
  parabola-prediction problem and fight the billiard readability we want for the
  first two sectors.

### 3.4 Star lighting

- A dim star has a **light radius** `R_star ≈ 2.5` board-units.
- A star **lights** the instant the spark's circle overlaps the star's light
  radius: `distance(sparkCenter, starCenter) ≤ r + R_star`.
- Lighting is **continuous-collision checked** along the swept path, so a fast
  spark passing *through* a star always lights it (no tunneling past it).
- **Multi-hit stars** (Sector 5) require N overlaps from **separate passes or
  separate shots**; consecutive frames of one overlap count as **one** hit (a
  short cooldown, ~0.15 s, prevents a single slow graze counting as multiple).
- Lighting is **permanent within a level attempt**: once lit, a star stays lit
  across subsequent shots in the same attempt (you are chipping away at the
  board). Restarting the level resets all stars to dim.

### 3.5 Shot / spark budget

- Each level defines a **spark count** `S` (the budget). Typical ranges by
  sector in `LEVEL_DESIGN.md`; early levels `S = 3–4`, later `S = 5–8`.
- The HUD shows remaining sparks as a row of spark icons that deplete L→R.
- **Par for 3 stars** (`par3`) is a per-level number ≤ `S` (see § 7).
- Budget interacts with boosters: **Extra Spark** raises `S` by 1 for that
  attempt; **Rewind** refunds the last-spent spark and reverts board state.

### 3.6 End-of-shot resolution

When the active shot ends (leaves play / black hole / time cap), the engine:

1. **Commits** any stars lit and stardust collected during the shot (they were
   shown lighting live; now they are locked in).
2. **Decrements** the spark budget (already decremented at launch in 3.2; this
   step just confirms the HUD).
3. Evaluates state:
   - **All stars lit → WIN** (jump to § 8 win flow immediately, even if sparks
     remain — remaining sparks improve the star rating, see § 7).
   - **Stars remain AND sparks remain → continue** (return control to player to
     aim the next shot; the spark respawns at `launchNode`).
   - **Stars remain AND sparks == 0 → LOSE** (§ 8 lose flow).
4. A brief **settle beat** (~0.4 s) plays before control returns, so the player
   registers what happened (which stars lit) without it feeling laggy.

---

## 4. Field elements (CONCEPT § 5, in depth)

Each element below specifies: **rules**, **spark interaction**, **visual cue**,
**audio cue**, and **design intent**. Intro level matches `CONCEPT.md` § 5.

### 4.1 Dim star — *intro Level 1*
- **Rules:** the win objective. A level is cleared when **all** dim stars are
  lit. Light radius `R_star ≈ 2.5` units.
- **Spark interaction:** lights on overlap (§ 3.4); stays lit for the attempt.
- **Visual cue:** a small, desaturated grey-blue star, gently pulsing (≈ 0.6 Hz)
  to read as "waiting." On lighting: a bright bloom, a burst of warm particles,
  and a steady glow that subtly lights nearby board.
- **Audio cue:** a clean, pitched "chime." When multiple light in quick
  succession, chimes ascend a pentatonic scale (combo feel).
- **Design intent:** the unit of progress; lighting one must always feel good.

### 4.2 Wall / asteroid — *intro Level 1*
- **Rules:** solid, static, impassable. Defined as segments / convex polygons.
- **Spark interaction:** perfectly elastic reflection, speed preserved (§ 3.3).
- **Visual cue:** chunky rocky silhouettes (asteroid) or clean geometric barriers
  (wall) with a faint rim light so edges are unambiguous. A tiny spark-flash and
  dust puff at the contact point.
- **Audio cue:** a soft, woody/stony "tock"; pitch slightly varies with impact
  speed.
- **Design intent:** the fundamental puzzle verb — bank shots. Clear edges =
  predictable bounces = readability.

### 4.3 Bumper — *intro ~Level 8*
- **Rules:** a bouncy pad that **adds energy** on contact. On bounce, speed is
  multiplied: `speed *= BUMP_GAIN` (`BUMP_GAIN` ≈ 1.4, capped at `MAX_SPEED`).
  Reflection direction follows the bumper's normal as a wall would.
- **Spark interaction:** reflects **and** accelerates; lets a slow, late-flight
  spark reach a far star.
- **Visual cue:** a rounded, springy puck that **compresses and rebounds** on
  hit, emitting a ring pulse. Distinct bright accent color (e.g., cyan).
- **Audio cue:** a satisfying "boing"/spring with an upward pitch sweep
  signaling the energy gain.
- **Design intent:** introduces *energy management*; turns "I can't reach" into
  "route through the bumper." Also a juice/delight beat.

### 4.4 Gravity well — *intro ~Level 18*
- **Rules:** an attractor with center `c`, radius of influence `R_g`, strength
  `G`. Each tick applies acceleration toward `c`:
  `a = G * dir(c) / max(d², D_MIN²)` (inverse-square, clamped near center so it
  never blows up). The spark's path **curves**; total mechanical readability is
  preserved because the field is *static and visualized*.
- **Spark interaction:** bends trajectory; can slingshot the spark around. Does
  **not** by itself end the shot (that is the black hole). Net effect trades a
  bit of straight-line speed for curvature but conserves energy overall.
- **Visual cue:** a translucent swirling vortex with curved streamlines showing
  the field direction; a faint boundary ring at `R_g`. The streamlines make the
  curve *predictable by eye*.
- **Audio cue:** a low, continuous "wub"/drone that swells as the spark nears.
- **Design intent:** first *curved* mechanic; teaches aiming into a bend.
  Guided Line preview is allowed to show the first curve to keep it fair.

### 4.5 Black hole (sink) — *intro ~Level 30*
- **Rules:** a hazard. Has an outer pull (like a gravity well) **and** an event
  horizon `R_eh`. If the spark crosses `R_eh`, the shot **ends immediately**
  (spark consumed, nothing lit by that doomed pass beyond contact point).
- **Spark interaction:** lures then **swallows**; a wasted shot. Pure avoid-me
  element. Distinct from gravity well: well bends, hole eats.
- **Visual cue:** a dark, light-bending disc with an accretion ring; nearby
  starlight visibly streams inward. A hard, clearly different silhouette from the
  gravity well (darker, with the horizon ring) so players never confuse them.
- **Audio cue:** an ominous low pull; on capture, a quick "whoomp/suck" and the
  ambience briefly ducks.
- **Design intent:** introduces *risk* and routing-around-danger; raises stakes
  in Sector 3 without adding twitch.

### 4.6 Portal / wormhole — *intro ~Level 40*
- **Rules:** portals come in **pairs** (A↔B). Entering one mouth exits the
  paired mouth, **preserving speed** and **re-emitting along the exit's facing**
  (the exit has an orientation; momentum is rotated into the exit frame). A
  short re-entry cooldown (~0.1 s) prevents instant re-trigger loops.
- **Spark interaction:** teleports; continues flight from the exit. Enables
  "impossible" routes and wrap-arounds.
- **Visual cue:** two matching ringed gateways sharing a color (pair A = violet,
  pair B = teal, etc.); a directional chevron at each mouth showing exit facing.
  The trajectory preview shows a "→" hint at the entry mouth.
- **Audio cue:** a "whoosh-in" at entry, "whoosh-out" at exit, panned to follow
  the spark.
- **Design intent:** spatial lateral-thinking; "the path leaves the screen here
  and reappears there." High delight when a player spots the route.

### 4.7 Moving obstacle — *intro ~Level 50*
- **Rules:** an asteroid or gate that drifts along a **timed, looping,
  deterministic path** (e.g., linear ping-pong, circular, or waypoint loop).
  Motion is a pure function of a level-local clock, so it is **fully
  predictable** and identical every attempt. Collides as a wall while moving.
- **Spark interaction:** the player must **time the launch** so the spark
  arrives when the gap is open / the obstacle is favorable. Note: timing is in
  the *launch decision*, not in mid-flight reflexes — still readable.
- **Visual cue:** the obstacle moves smoothly with a faint **ghost trail / dotted
  future-path** so the player can read its cycle. A subtle on-board beat pulse
  marks the loop period.
- **Audio cue:** a soft rhythmic "tick" at the loop boundary; mechanical
  "clank" if a gate closes on the spark.
- **Design intent:** adds a **timing layer** without sacrificing determinism;
  the puzzle becomes "aim *and* choose the right moment."

### 4.8 Color-locked star — *intro ~Level 60*
- **Rules:** a star tinted a specific color (e.g., red/blue/green). It only
  lights if the spark's **current color matches**. Color is changed by passing
  through **color gates/prisms** placed on the board (entering a red prism makes
  the spark red, etc.).
- **Spark interaction:** the spark must be routed through the correct prism
  *before* reaching the star; a mismatched spark passes through harmlessly
  (no light, with a soft "denied" cue).
- **Visual cue:** the star and its required color share a hue; the spark's comet
  trail recolors instantly when it passes a prism. A "✗" shimmer on a mismatched
  touch.
- **Audio cue:** a "filter sweep" when recoloring; a dull "thud-no" on mismatch.
- **Design intent:** adds an **ordering/sequencing** constraint (visit prism →
  then star), deepening puzzles in Sector 4.

### 4.9 Multi-hit star — *intro ~Level 70*
- **Rules:** needs **2–3** touches to fully light. Each touch advances a pip
  ring; the star fully lights (and counts toward win) only at the final touch.
  Hits can come from one looping shot (multiple passes) or across multiple
  sparks. Cooldown 0.15 s between counted hits (§ 3.4).
- **Spark interaction:** rewards routes that pass through the same star multiple
  times, or budgeting multiple sparks at one tough star.
- **Visual cue:** a segmented ring around the star, filling per hit (1/3, 2/3,
  3/3); the star brightens in stages and fully blooms on the last.
- **Audio cue:** a rising two-/three-note motif, one note per hit, resolving on
  completion.
- **Design intent:** *resource/route weighting* — one star can dominate your
  spark budget; teaches prioritization.

### 4.10 Switch / gate — *intro ~Level 80*
- **Rules:** hitting a **switch** toggles a **barrier/gate** elsewhere (opens a
  closed wall, or closes an open path). Switches can be momentary (open while/
  shortly after hit) or latching (toggle and stay). A switch may control one or
  several gates.
- **Spark interaction:** introduces **state**: the board changes based on what
  you have hit this attempt; solutions become multi-step ("hit switch, *then*
  the now-open lane to the star").
- **Visual cue:** switch is a clearly tappable plate that depresses and glows on
  activation; linked gates share its accent color and animate open/closed with a
  connecting light-line so the linkage is unambiguous.
- **Audio cue:** a mechanical "ka-chunk" on switch; a sliding "shhk" as the gate
  moves.
- **Design intent:** the **capstone** mechanic — puzzles become small machines
  with order-of-operations. Combines naturally with everything prior.

---

## 5. Power-ups / boosters

Per `CONCEPT.md` § 7. Boosters are equipped **pre-level (loadout, up to 3)** and
some are also offered **in-level on a "stuck?" prompt** or **on fail**. None are
required to clear any level (no pay-to-win); they save time and smooth spikes.

| Booster | Exact effect | Offered | Cost (target) | Balance notes |
|---|---|---|---|---|
| **Guided Line** | Extends trajectory preview from 2 → **5 reflections** and through the **first gravity-well curve**, for the whole level. | Loadout | Coins (cheap, ~50) | Lowers difficulty by removing guesswork on bank shots; never reveals moving-obstacle futures or 2nd portal hop, so deep puzzles still require thought. Best value in Sectors 1–3. |
| **Slow-Mo** | While the spark is in flight, hold to slow sim time to **0.35×** (direction unchanged). One charge = up to ~3 s of slow, or until shot ends. | Loadout + in-level "stuck?" | Coins (~75) | Helps with moving obstacles & tight gravity curves by giving the *eye* more time — but never changes the path, preserving determinism. Cannot rescue a fundamentally wrong aim. |
| **Extra Spark** | `+1` to the spark budget `S` for this attempt. | Loadout + **on fail** (often as a **rewarded-ad** offer) | Coins (~100) or 1 rewarded ad | The primary "so close" save; the rewarded-ad version is a key, value-positive monetization beat (CONCEPT § 9). Cap: at most **+2** per attempt via this booster to avoid trivializing par. Does **not** count against `par3` — using it caps you at ≤2 stars (see § 7). |
| **Bomb Spark** | The next launched spark **detonates on first impact**, clearing **nearby asteroids/walls** within radius `R_bomb ≈ 8` units (not indestructible bedrock walls, not stars, not black holes). | Loadout | Coins (~120) | Powerful; restricted to *destructible* obstacles only (levels flag which walls are destructible). Opens otherwise-blocked lanes. Limited per level (max 1 equipped) so it is a tactical key, not a sledgehammer. |
| **Rewind** | Undoes the **last shot**: refunds 1 spark and reverts all stars/stardust/state changed by that shot. | Loadout + in-level button | Stardust (premium) or Coins (~150) | The "take-back." Premium-leaning because it removes consequence. Limited to **one queued rewind** at a time (you cannot stack-undo to the start; full reset is the free Restart). |

**Loadout UX:** before entering a level the player sees up to 3 booster slots
(empty by default). New players have slots locked/hidden until the booster
concept is taught (~Sector 1 end), per tutorialization philosophy (§ 9).

**"Stuck?" offers:** if the player has used `≥ ceil(0.6·S)` sparks with
`> half` the stars still dim, a gentle, dismissible prompt offers a single
relevant booster (often a rewarded-ad Slow-Mo or, on the *next* fail, Extra
Spark). Frequency-capped; never blocks the board; always skippable. Serves "one
more try," not frustration-monetization.

---

## 6. Progression & difficulty curve

### 6.1 Structure (CONCEPT § 6)
100 handcrafted levels, **5 sectors × 20**:

| Sector | Levels | Theme | New mechanics | Difficulty band |
|---|---|---|---|---|
| 1 Embers | 1–20 | first light | aim, walls, bounce, **bumper** (~8) | Tutorial → Easy |
| 2 Nebula | 21–40 | colored gas | **gravity wells**, more bumpers | Easy → Medium |
| 3 Void | 41–60 | dark & dangerous | **black holes**, **portals** | Medium → Hard |
| 4 Pulsar | 61–80 | rhythmic | **moving obstacles**, **color locks** | Hard |
| 5 Singularity | 81–100 | everything | **multi-hit**, **switches**, full combo | Hard → Expert |

### 6.2 Escalation *within* a sector
Each sector is a **mini-arc** of ~20 levels:
- **Levels x1–x3:** teach the sector's new mechanic in isolation (gentle,
  generous spark budget, near-impossible-to-fail framing).
- **Levels x4–x12:** combine the new mechanic with prior ones; tighten spark
  budgets and `par3`; introduce variations.
- **Levels x13–x18:** challenge levels — multi-step routes, tighter budgets,
  the mechanic at full expression.
- **Level x19:** a "calm before the boss" — a satisfying, slightly easier
  showcase level so the player enters the finale confident.
- **Level x20:** **Supernova** finale (§ 8.5).

Difficulty within a sector follows a **sawtooth**: it climbs, then **resets
down** at each sector boundary as a fresh mechanic is introduced gently, then
climbs higher than the previous peak. Net curve trends up across the game.

### 6.3 Pacing of new-mechanic introductions
- **Never more than one new element per ~3 levels.** (Pillar 3.)
- A new mechanic is **always introduced alone first**, then combined.
- After a hard challenge level, the next level is deliberately a notch easier
  (rhythm of tension/release). Target average **fail rate per level**: ~15–25%
  in challenge levels, <8% in teaching levels (retuned by telemetry —
  `LEVEL_DESIGN.md`).

### 6.4 Tutorialization philosophy — *"teach by level design"*
- **Show, don't tell.** New mechanics are taught by a level whose layout makes
  the correct interaction nearly the *only* thing you can do. (E.g., the bumper
  intro level places a single star reachable *only* by routing through one
  obvious bumper.)
- Text is reduced to at most a **one-line, one-time tooltip** ("Bumpers add
  speed!") that appears the first time an element is seen and never again.
- The **trajectory preview is the primary teacher**: players learn physics by
  watching the dotted line respond to their drag.
- No forced multi-step tutorial sequences beyond Level 1's "drag, release,
  light a star." Target tutorial completion ≥ 85% (CONCEPT § 13).

---

## 7. Star rating rules (exact scheme)

Each level grants **0–3 stars** based on **efficiency (sparks used)** and
**optional stardust** collected. We use a **hybrid, deterministic** scheme.

**Per-level authored values** (in level data, see `LEVEL_DESIGN.md`):
- `S` — spark budget.
- `par3` — sparks at/under which the player earns the efficiency component for
  3 stars. Always `par3 ≤ S`. Typically `par3 = number_of_stars_minimum` route.
- `par2` — looser threshold for the 2-star efficiency tier (`par2 ≥ par3`,
  `par2 ≤ S`). If unset, default `par2 = par3 + 1`.
- `stardustTotal` — count of optional stardust motes on the board (often 1–3;
  may be 0 if the level uses pure efficiency).

**Rating algorithm (evaluated on WIN):**

```
sparksUsed = S_effective_at_start - sparksRemaining   // boosted sparks count as used
allStardust = (stardustCollected == stardustTotal)    // true if no stardust authored

efficiencyStars =
    3  if sparksUsed <= par3
    2  if sparksUsed <= par2
    1  otherwise (cleared, but over par2)

rating = efficiencyStars
// Stardust gate: you cannot reach 3 stars while leaving stardust uncollected.
if stardustTotal > 0 and not allStardust:
    rating = min(rating, 2)
// Booster integrity: using Extra Spark (raising S) caps the rating.
if extraSparkUsedThisAttempt:
    rating = min(rating, 2)

rating = max(rating, 1)   // any clear is at least 1 star
```

**Plain-English version:**
- **1 star** = you cleared the level (always at least this).
- **2 stars** = cleared at/under `par2` sparks **and/or** missing some stardust.
- **3 stars** = cleared at/under `par3` sparks **and** collected **all**
  stardust **and** did **not** use Extra Spark. (Mastery.)

**Why hybrid:** efficiency rewards skillful routing (the core skill), while
optional stardust gives an **alternate mastery axis** and a reason to find the
*elegant* route, not just the cheap one. Stardust placement is the level
designer's tool to push players toward the intended beautiful solution.

**Stars feed the meta:** total stars gate sector unlocks (§ 6.1 / CONCEPT § 6),
and per-level star count is shown on the level-select map.

---

## 8. Win / lose / restart / undo

### 8.1 Win
- **Condition:** all dim stars lit (multi-hit fully lit), evaluated at any
  shot resolution (or mid-shot the instant the last star lights — we let the
  current shot finish its arc for spectacle, then resolve).
- **Flow:** freeze → cascade "relight" VFX across the constellation → star
  rating tally (animated 1→2→3 fill) → reward popup (coins, XP, any stardust
  bonus) → "Next" / "Replay" / level-select. Interstitial ad may show here,
  frequency-capped (CONCEPT § 9).

### 8.2 Lose
- **Condition:** spark budget reaches 0 with ≥ 1 star still dim.
- **Flow:** gentle "the dark holds" beat (no harsh fail sting — pillar 2) →
  offer **Extra Spark** (rewarded ad or coins) to continue *this attempt*
  without losing a life → else **Retry** (costs a life) / **Quit**.

### 8.3 Restart (instant)
- Always available via an on-screen button. **One tap**, sub-200 ms, resets all
  stars to dim, refills sparks to `S`, resets switches/gates/moving-obstacle
  clock to the level's initial state. Costs **no life** if the level was not
  yet failed (you may freely restart a still-winnable attempt). A retry *after*
  a loss costs a life.

### 8.4 Undo / Rewind (booster)
- **Rewind** (§ 5) reverts exactly the **last shot**: refunds 1 spark, restores
  pre-shot star/stardust/switch/gate state. Implemented via an **immutable
  board-state snapshot** pushed before each launch (cheap; state is small). One
  level of undo (no multi-step stack); the free Restart covers "back to start."

### 8.5 Boss / finale — "Supernova" (levels 20/40/60/80/100)
Per CONCEPT § 5: **not a real-time boss fight** — a harder puzzle with theatrics.

**Common Supernova rules:**
- The centerpiece is an **unstable star** that requires **multiple precise
  hits** (a special multi-hit star with `N = 4–6`) to fully ignite and clear.
- Around it, the **field shifts / hazards intensify in scripted, deterministic
  phases** as you land hits:
  - **Phase 1 (hits 0→2):** base layout; learn the safe route.
  - **Phase 2 (hits 2→4):** new walls slide in / a gravity well or moving gate
    activates, changing the route (telegraphed, deterministic).
  - **Phase 3 (final hits):** the most demanding configuration; a tight window.
- Generous spark budget relative to difficulty (e.g., `S = 8–12`), because the
  fantasy is **persistence and a big payoff**, not punishment.
- Each phase transition has **heightened juice** (screen flush of color, a music
  swell, slow-mo on the final igniting hit).

**Per-sector Supernova flavor:**
- **L20 (Embers):** unstable ember-star; phases add asteroid walls — pure
  bank-shot mastery test. The "graduation" of Sector 1's skills.
- **L40 (Nebula):** gravity wells swirl in during phases, bending your banks —
  tests reading curves under pressure.
- **L60 (Void):** a black hole creeps toward the unstable star each phase; the
  safe corridor narrows — risk management climax.
- **L80 (Pulsar):** moving gates + a color-lock on the final hits (must arrive
  the right color at the right moment) — timing + sequencing climax.
- **L100 (Singularity):** the grand finale — multi-hit core + switches that
  reshape the board each phase + a cameo of every prior mechanic. The hardest,
  most theatrical level; clearing it "relights the galaxy" (a full-screen
  payoff cutscene).

**Finale clear** awards bonus coins/stardust and unlocks the next sector.

---

## 9. Tutorial & hint system

### 9.1 Tutorial (teach-by-design, § 6.4)
- **Level 1** is the only scripted moment: a soft, animated hand demonstrates
  *drag-back → release*, the preview line appears, and a single star sits
  directly in the launch lane. Impossible to fail; teaches the verb in ~10 s.
- Every subsequent **first appearance** of an element triggers a one-time,
  one-line tooltip and a level whose design isolates that element (§ 4 intro
  levels). No tooltip ever repeats.
- Tutorials are skippable for returning players (flag in save data) and never
  block input for more than a beat.

### 9.2 Hint system
- **Passive nudges:** after a failed attempt or prolonged idle, the trajectory
  preview can briefly **pulse a suggested aim cone** toward an unlit star
  (rough, not a full solution — it points, it doesn't solve). Off by default in
  later sectors; tunable via Remote Config.
- **"Stuck?" offer** (§ 5): on the configured stuck-condition, a dismissible
  booster suggestion (Slow-Mo / Guided Line) appears.
- **Solution hint (premium/rewarded):** an optional "Show me" that plays a
  ghost trajectory of *one valid* solving shot, gated behind a rewarded ad or
  small coin cost, capped per level. Never auto-shown; always opt-in. Preserves
  the "I solved it" feeling for everyone who doesn't ask.
- All hints respect pillar 1 (readable) and pillar 2 (never condescending,
  never forced).

---

## 10. Player retention hooks (CONCEPT § 7–8)

Tied to the economy & live features so the core puzzle stays clean:

- **Lives (energy):** 1 / 20 min, cap 5; spent on a *failed* attempt (clears and
  free restarts cost nothing). Creates gentle session bounding and a return
  reason; refillable via coins, rewarded ad, or IAP. **Never** blocks a player
  mid-win-streak harshly — designed to be felt only when failing repeatedly.
- **Daily Challenge:** one special handcrafted/curated level per day; **streak**
  multiplies rewards. A reason to open the app every day.
- **Daily reward / login streak, Lucky Wheel, Chests:** escalating daily coin/
  booster drips; the Wheel/Chests add variable-reward delight (capped, never
  pay-walled to progress).
- **Missions (daily/weekly):** e.g., "light 50 stars," "clear 3 levels with 3
  stars," "use a bumper route 5 times" — drive varied play and reward coins/XP.
- **Achievements & XP / Player Level:** long-tail goals; XP unlocks cosmetic
  spark skins & backgrounds and profile flair (status, not power).
- **Events & seasonal packs:** themed level batches and limited cosmetics; the
  big re-engagement spikes.
- **Leaderboards:** by total stars and by event score, friends + global
  (post-MVP per CONCEPT § 12).
- **Star-chase 3-star replays:** the rating system itself is a retention hook —
  players return to convert 1–2★ levels into 3★ mastery.

Economy guardrails (no pay-to-win): every level solvable for free; IAP/ads buy
**time, smoothing, and flair**, never exclusive solutions (CONCEPT § 9, § 12).

---

## 11. Game feel & juice guidelines

The whole product thesis is **"calm board, joyful payoff"** (pillar 4). Juice is
concentrated on *success*; the resting state is serene.

### 11.1 The hit (lighting a star) — must feel great
- **Visual:** instant bright bloom + radial warm-particle burst (20–40 motes,
  short-lived), a quick scale-pop on the star (overshoot ease, e.g.
  `easeOutBack`), and a soft expanding light ring that briefly illuminates the
  nearby board.
- **Audio:** crisp pitched chime; chain-lights ascend a pentatonic scale.
- **Haptic:** a light, short impact (iOS `lightImpact` / Android equivalent) per
  star lit. Multi-light = a gentle quick double.
- **Time:** optional **micro slow-mo (~0.2× for ~120 ms)** on the *final* star
  of a level so the win moment breathes.

### 11.2 Bounces & elements
- **Wall bounce:** tiny contact spark + dust puff, a soft "tock," a *very* small
  screen-shake (≤ 2 px) only on high-speed impacts — restraint is key.
- **Bumper:** spring squash-and-stretch, ring pulse, "boing" with up-pitch; a
  slightly stronger haptic tick (this is a celebrated moment).
- **Gravity well / black hole:** continuous swirl/streamline motion, low drone;
  black-hole capture gets a brief ambience duck + a sharp "whoomp."
- **Portal:** in/out whooshes panned to the spark; a quick flash at each mouth.

### 11.3 Win celebration
- Constellation **relight cascade** (stars pop on in sequence), background
  blooms from dark to softly lit, a warm music swell, star-tally chimes (one per
  earned star), and a **gentle** confetti-of-stardust. Stronger screen shake is
  allowed here (it's the payoff) but still tasteful.
- **Supernova finale** scales all of this up: full-screen color flush, slow-mo
  on the igniting hit, and (L100) a brief "galaxy relit" cutscene.

### 11.4 Easing & motion language
- UI and game motion use **spring/ease curves**, never linear. Defaults:
  `easeOutCubic` for entrances, `easeOutBack` for celebratory pops,
  `easeInOutCubic` for camera/board nudges.
- The aim band stretches with a slight elastic feel; release snaps.
- Subtle, slow **parallax starfield** background for depth without distraction.

### 11.5 Audio direction
- **"Lofi space":** soft ambient pads + light lofi beat under play; ducks for SFX
  clarity. Music is *quiet*; the board should feel meditative. Stingers and
  chimes are the bright spots.
- Full **mute / SFX-only / music-only** options; respect system silent switch.

### 11.6 Performance & restraint guardrails
- Target **60 FPS on mid-tier devices** (CONCEPT § 13); particle counts and
  shake are budgeted to never drop frames. When in doubt, **less juice** — a
  janky celebration feels worse than a clean one. Juice scales down gracefully
  on low-end devices (a "reduced effects" quality tier).
- **Accessibility:** reduced-motion mode (cuts shake/slow-mo, keeps essential
  feedback), colorblind-safe palettes for color-locked mechanics (shape/symbol
  redundancy on prisms & color-locked stars), and haptics toggle.

---

## 12. Open tuning questions (for telemetry-driven retune)

- Exact `BUMP_GAIN`, `MAX_SPEED`, gravity `G`, preview reflection counts.
- Per-sector spark budgets and `par3`/`par2` defaults.
- "Stuck?" trigger thresholds and hint aggressiveness.
- Lives regen rate / cap and interstitial cadence.

All of the above are exposed via **Remote Config** and retuned against live
fail-rate and retention metrics (see `LEVEL_DESIGN.md` § Difficulty balancing).
The *mechanics* in this document are fixed; only the *numbers* flex.
