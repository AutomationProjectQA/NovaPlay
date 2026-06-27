# NovaPlay — Level Design Document & Plan

> **Sprint 10 plan.** Derives from `CONCEPT.md` (Locked v1.0) and `GAME_DESIGN.md`
> (Sprint 2). Defines the level data model, coordinate conventions, the 5-sector
> content plan, balancing methodology, authoring pipeline, unlock/gating, and QA.
>
> Status: **Draft for review** · Owner: Level Design · Last updated: Sprint 10.

---

## 1. Level design philosophy & goals

NovaPlay's content lives or dies on the **feel of each level**. The pillars from
`CONCEPT.md` § 2 translate to concrete level-design rules:

1. **One idea per few levels.** Each level has a **single primary teaching or
   challenge idea**. If a level is "about" three things, it is three levels.
   (Pillar: elegant escalation.)
2. **Design for the "aha."** The best levels look hard, then reveal an elegant
   route the player *discovers*. The designer hides the elegant solution in
   plain sight (often marked by stardust placement) and makes brute force
   inefficient, not impossible.
3. **Fairness is sacred.** Every level must be:
   - **Solvable for free** (no booster required) — proven by an authored
     reference solution stored with the level.
   - **Readable** — the intended route is discoverable from the board + preview;
     no pixel-perfect "lucky" requirements; the spark radius is generous.
   - **Deterministic** — same input ⇒ same outcome, every attempt, every device.
4. **Tension/release rhythm.** Within a sector, alternate harder and softer
   levels; never stack three brutal levels in a row (see beat sheets, § 4).
5. **Teach by design, not text.** A mechanic's intro level is constructed so the
   correct interaction is nearly the only available action (`GAME_DESIGN.md`
   § 6.4).
6. **Respect the budget.** Spark budget `S` and `par3` are the designer's
   primary difficulty dials. Generous `S` for teaching, tight `S` + tight `par3`
   for mastery.

**Per-level acceptance bar (a level is "done" only if):**
- [ ] Has ≥ 1 authored reference solution that clears it within `par3` sparks
      using **no boosters**.
- [ ] Has a single clear primary idea.
- [ ] Stardust (if any) sits on or near the *intended elegant* route.
- [ ] Passes the QA checklist (§ 8).
- [ ] Validated by the schema/solvability tooling (§ 6).

---

## 2. Level data model

Levels are **data, not code**: authored as JSON, shipped as bundled assets, and
loaded into immutable Flutter models (`freezed` + `json_serializable` per
`CONCEPT.md` § 11). Player **progress** (stars, unlocks) lives in **Hive**;
**level definitions** are read-only assets (optionally overridable by Firebase
Remote Config / Firestore for events & live retuning, § 5).

### 2.1 Schema (conceptual)

| Field | Type | Notes |
|---|---|---|
| `id` | int | Global level id, 1–100 (and 1000+ for event/daily levels). |
| `sector` | int | 1–5. |
| `indexInSector` | int | 1–20. |
| `version` | int | Schema/content version for migration. |
| `name` | string | Display/debug name (e.g., "First Light"). |
| `board` | object | Coordinate space: `{ width, height }` in board-units (canonical 100 × 178, portrait ≈ 9:16). |
| `launchNode` | vec2 | Spark spawn point (board-units), usually bottom-center. |
| `sparks` | int | Spark budget `S`. |
| `par3` | int | Sparks at/under which 3★ efficiency is earned (`≤ sparks`). |
| `par2` | int | 2★ threshold (`par3 ≤ par2 ≤ sparks`); default `par3+1`. |
| `stars` | array&lt;Star&gt; | Dim stars to light (the objective). |
| `stardust` | array&lt;vec2&gt; | Optional collectible motes; `stardustTotal = length`. |
| `obstacles` | array&lt;Obstacle&gt; | All field elements (walls, bumpers, wells, etc.). |
| `introMechanic` | string\|null | If set, this level first-introduces the named mechanic ⇒ triggers one-time tooltip + tutorial framing. |
| `referenceSolution` | array&lt;ShotVec&gt; | Authored solving shots (aim+power), used for solvability validation; not shipped to clients (or stripped in release). |
| `tags` | array&lt;string&gt; | e.g., `["teach","challenge","calm","supernova"]`. |
| `remoteOverridable` | bool | If true, Remote Config may patch `sparks`/`par`/positions for live retune. |

**`Star`**: `{ pos: vec2, hits: int = 1, color: string|null }`
- `hits > 1` ⇒ multi-hit star (Sector 5). `color` ⇒ color-locked (Sector 4).

**`Obstacle`** (discriminated by `type`):

| `type` | Params | Element (GDD § 4) |
|---|---|---|
| `wall` | `points: [vec2...]` (polyline/polygon), `destructible: bool` | Wall / asteroid |
| `bumper` | `pos`, `normal` (facing), `gain: 1.4`, `shape` | Bumper |
| `gravityWell` | `pos`, `radius`, `strength` | Gravity well |
| `blackHole` | `pos`, `pullRadius`, `eventHorizon`, `strength` | Black hole (sink) |
| `portal` | `pos`, `facing`, `pairId` | Portal (matched by `pairId`) |
| `mover` | `shape`, `path: [waypoints...]`, `period`, `loopMode` (`pingpong`\|`loop`\|`circle`) | Moving obstacle |
| `prism` | `pos`, `radius`, `color` | Color gate (recolors spark) |
| `switch` | `pos`, `targets: [gateId...]`, `mode` (`momentary`\|`latch`) | Switch |
| `gate` | `id`, `points`, `initialOpen: bool` | Switch-controlled barrier |

All positions/sizes are in **board-units** (§ 3). Angles in degrees, CCW from +x.

### 2.2 Concrete example level (JSON)

A representative **Sector 1, Level 8** — the bumper-introduction level. One star,
reachable only by banking off a wall *into* a bumper that boosts the spark up to
the star. Stardust sits on the elegant direct-bank line.

```json
{
  "id": 8,
  "sector": 1,
  "indexInSector": 8,
  "version": 1,
  "name": "Springboard",
  "board": { "width": 100, "height": 178 },
  "launchNode": { "x": 50, "y": 168 },
  "sparks": 4,
  "par3": 1,
  "par2": 2,
  "introMechanic": "bumper",
  "tags": ["teach", "bumper"],
  "stars": [
    { "pos": { "x": 78, "y": 40 }, "hits": 1, "color": null }
  ],
  "stardust": [
    { "x": 30, "y": 96 }
  ],
  "obstacles": [
    {
      "type": "wall",
      "points": [ { "x": 6, "y": 120 }, { "x": 6, "y": 60 } ],
      "destructible": false
    },
    {
      "type": "bumper",
      "pos": { "x": 22, "y": 70 },
      "normal": 35,
      "gain": 1.4,
      "shape": "round"
    },
    {
      "type": "wall",
      "points": [ { "x": 94, "y": 150 }, { "x": 94, "y": 90 } ],
      "destructible": false
    }
  ],
  "referenceSolution": [
    { "aimDeg": 118, "power": 0.62 }
  ],
  "remoteOverridable": true
}
```

Reading this: the player drags down-right, the spark flies up-left, banks off the
left wall, hits the bumper which boosts it up-right, collecting the stardust mote
on the bank line and lighting the star at (78,40) in a single elegant shot
(`par3 = 1`, so 1★/2★/3★ all achievable based on stardust + spark efficiency).

---

## 3. Coordinate system & board conventions

- **Board units, not pixels.** Canonical board is **100 (w) × 178 (h)**
  board-units, an ≈ 9:16 portrait field. The renderer maps board-units to the
  device viewport with letterboxing/safe-area handling, so levels are
  resolution-independent.
- **Origin:** **top-left = (0,0)**; **+x right, +y down** (standard screen/Flame
  convention). All authored data uses this frame. (Internally the physics is
  frame-agnostic; the convention just keeps authoring consistent.)
- **Angles:** degrees, **CCW from +x axis** in the math frame. `aimDeg` in a
  reference solution is the *launch* direction (already resolved from the
  pull-back metaphor, GDD § 3.1).
- **Launch node** default: `(50, 168)` — bottom-center, ~6% above the bottom
  safe area for thumb comfort.
- **Margins:** keep all interactive geometry within an **inner safe rect** of
  ~`[4 … 96] × [8 … 170]`; the outer band is reserved for HUD/safe-area and is
  the "leaves play" boundary (a spark exiting the board ends the shot).
- **Grid for authoring:** positions snap to a **0.5-unit** soft grid in the
  editor for clean geometry, but the format stores arbitrary doubles.
- **Spark radius** `r ≈ 1.2`, **star light radius** `R_star ≈ 2.5` (GDD § 3) —
  designers must leave ≥ `r + R_star + 1` clearance so intended near-misses read
  as misses and intended hits read as hits.

---

## 4. The 5 sectors — themes, mechanics, bands, beat sheets

Conventions: `S` = spark budget, beat-sheet entries note the **idea** and rough
difficulty (☆ easy → ★★★ expert). `x` = sector, so levels are `x01…x20`. Every
`x20` is a **Supernova** finale (GDD § 8.5). Beat sheets give a representative,
buildable breakdown — designers fill remaining levels following the same arc.

---

### Sector 1 — Embers (Levels 1–20)
- **Theme:** the first sparks of light in a dead-grey starfield; warm embers.
- **Mechanics introduced:** drag-to-aim, walls/asteroids (bounce), **bumper** (~L8).
- **Difficulty band:** Tutorial → Easy. Generous `S` (3–4). Fail rate target <10%.

| Lvl | Idea / beat | Diff | `S` | Notes |
|---|---|---|---|---|
| 1 | **Teach aim+launch.** One star in the direct launch lane. | ☆ | 3 | Scripted hand tutorial; `introMechanic: aim`. |
| 2 | Two stars in a line — one shot can light both. | ☆ | 3 | Teaches "a shot can light multiple." |
| 3 | **Teach the bank shot.** Star reachable only by one wall bounce. | ☆ | 3 | `introMechanic: wall`. |
| 4 | Two-wall bank (a corner pocket). | ☆ | 3 | Reinforces reflection. |
| 5 | Two stars needing two different shots. | ☆☆ | 4 | Teaches spending multiple sparks. |
| 6 | Tighter single bank; first stardust mote on the line. | ☆☆ | 3 | Teaches stardust/3★ chase. |
| 7 | Bank into a gap (precision). | ☆☆ | 3 | — |
| 8 | **Teach bumper** (see § 2.2 example). | ☆☆ | 4 | `introMechanic: bumper`. |
| 9 | Bumper to reach a far star. | ☆☆ | 3 | — |
| 10 | Bumper + bank combo. | ★ | 4 | First mild combo. |
| 11 | Two stars, one via bumper, one direct. | ★ | 4 | — |
| 12 | Narrow corridor bank (readability test). | ★ | 3 | — |
| 13 | Challenge: 3 stars, tight `par3`. | ★ | 4 | First "challenge" tag. |
| 14 | Double bumper chain. | ★ | 4 | — |
| 15 | Stardust forces the elegant route. | ★ | 4 | 3★ requires the clever line. |
| 16 | Challenge: bumper + 2 banks. | ★★ | 4 | — |
| 17 | Asteroid cluster maze (banks). | ★★ | 5 | — |
| 18 | Challenge: 3 stars, `par3=2`. | ★★ | 4 | — |
| 19 | **Calm before boss** — satisfying showcase. | ★ | 5 | Confidence builder. |
| 20 | **SUPERNOVA (Embers):** unstable ember-star, `hits=4`; phases slide in asteroid walls. Pure bank mastery. | ★★ | 9 | `tags:["supernova"]`. |

---

### Sector 2 — Nebula (Levels 21–40)
- **Theme:** drifting colored gas clouds; soft glowing nebulae.
- **Mechanics introduced:** **gravity wells** (~L18 in concept ≈ here at L21–23),
  more advanced bumper use.
- **Difficulty band:** Easy → Medium. `S` 4–6.

| Lvl | Idea / beat | Diff | `S` |
|---|---|---|---|
| 21 | **Teach gravity well** — star reachable only by letting the path curve. `introMechanic: gravityWell`. | ☆☆ | 4 |
| 22 | Aim *past* a well; let it bend you in. | ☆☆ | 4 |
| 23 | Well + a single bank. | ★ | 4 |
| 24 | Two wells creating an S-curve. | ★ | 5 |
| 25 | Well slingshot to a far star. | ★ | 4 |
| 26 | Bumper feeding into a well curve. | ★ | 5 |
| 27 | Challenge: thread a well between two walls. | ★★ | 4 |
| 28 | Two stars, one needs the curve, one direct. | ★ | 5 |
| 29 | Well placement makes brute force overshoot. | ★★ | 4 |
| 30 | Challenge: bank → well → star. | ★★ | 5 |
| 31 | Double-well figure-eight route. | ★★ | 6 |
| 32 | Stardust on the curved-elegant line. | ★★ | 5 |
| 33 | Well + bumper energy puzzle. | ★★ | 5 |
| 34 | Challenge: 3 stars across two wells. | ★★ | 6 |
| 35 | Tight corridor with a well pulling you off-line. | ★★ | 5 |
| 36 | Challenge: `par3=2`, well-heavy. | ★★★ | 5 |
| 37 | Wells + asteroid maze. | ★★★ | 6 |
| 38 | Challenge: orbit a well to hit two stars in one shot. | ★★★ | 5 |
| 39 | **Calm before boss.** | ★ | 6 |
| 40 | **SUPERNOVA (Nebula):** unstable star `hits=5`; phases activate gravity wells that bend your banks. | ★★★ | 10 |

---

### Sector 3 — Void (Levels 41–60)
- **Theme:** dark, sparse, dangerous deep space.
- **Mechanics introduced:** **black holes** (~L41–43), **portals** (~L48–50).
- **Difficulty band:** Medium → Hard. `S` 4–7. Risk management enters.

| Lvl | Idea / beat | Diff | `S` |
|---|---|---|---|
| 41 | **Teach black hole** — obvious hazard to route around. `introMechanic: blackHole`. | ★ | 4 |
| 42 | Black hole between launcher and star (go around). | ★ | 4 |
| 43 | Black hole near a bank target (precision under risk). | ★★ | 4 |
| 44 | Well *and* hole — distinguish bend vs. eat. | ★★ | 5 |
| 45 | Narrow safe corridor past a hole. | ★★ | 4 |
| 46 | Two holes; thread the gap. | ★★★ | 5 |
| 47 | Challenge: hole guards the only stardust. | ★★★ | 5 |
| 48 | **Teach portal** — pair A↔B; route through to an unreachable star. `introMechanic: portal`. | ★ | 4 |
| 49 | Portal that reverses direction (wrap-around). | ★★ | 4 |
| 50 | Portal + bank to align the exit. | ★★ | 5 |
| 51 | Two portal pairs (pick the right one). | ★★ | 5 |
| 52 | Portal exit aimed at a black hole — careful! | ★★★ | 5 |
| 53 | Challenge: portal → well → star. | ★★★ | 5 |
| 54 | Portal chain to hit two stars. | ★★★ | 6 |
| 55 | Hole + portal + bumper combo. | ★★★ | 6 |
| 56 | Challenge: stardust only via a risky portal hop. | ★★★ | 5 |
| 57 | Tight: portal exit into a narrow lane past a hole. | ★★★ | 5 |
| 58 | Challenge: 3 stars, mixed portals/holes, `par3=2`. | ★★★ | 6 |
| 59 | **Calm before boss.** | ★★ | 7 |
| 60 | **SUPERNOVA (Void):** unstable star `hits=5`; a black hole creeps toward it each phase, narrowing the safe corridor. Portals offer escape routes. | ★★★ | 11 |

---

### Sector 4 — Pulsar (Levels 61–80)
- **Theme:** rhythmic, pulsing pulsar beats; everything has a tempo.
- **Mechanics introduced:** **moving obstacles** (~L61–63), **color locks**
  (prisms + color-locked stars, ~L68–70).
- **Difficulty band:** Hard. `S` 5–7. Timing + sequencing layers.

| Lvl | Idea / beat | Diff | `S` |
|---|---|---|---|
| 61 | **Teach moving obstacle** — wait for the gate to open, then launch. `introMechanic: mover`. | ★★ | 5 |
| 62 | Ping-pong asteroid blocking the lane. | ★★ | 5 |
| 63 | Circular mover orbiting the star. | ★★★ | 5 |
| 64 | Two movers, alternating windows. | ★★★ | 6 |
| 65 | Mover + bank timing. | ★★★ | 5 |
| 66 | Challenge: mover guards stardust; window is tight. | ★★★ | 6 |
| 67 | Mover + black hole (timing + risk). | ★★★ | 6 |
| 68 | **Teach color lock** — one prism, one matching star. `introMechanic: prism`. | ★★ | 5 |
| 69 | Wrong-color star (must skip it / route through prism first). | ★★★ | 5 |
| 70 | Two colors, two prisms, two locked stars (ordering). | ★★★ | 6 |
| 71 | Prism then bank then star. | ★★★ | 6 |
| 72 | Color lock + mover combo. | ★★★ | 6 |
| 73 | Challenge: collect right color before a moving gate closes. | ★★★ | 6 |
| 74 | Two prisms in series (last one wins) — sequencing trap. | ★★★ | 6 |
| 75 | Challenge: color-locked stardust. | ★★★ | 6 |
| 76 | Color + portal (recolor, then teleport). | ★★★ | 7 |
| 77 | Challenge: 3 locked stars, one shot each, tight `par3`. | ★★★ | 7 |
| 78 | Everything-Sector-4 combo gauntlet. | ★★★ | 7 |
| 79 | **Calm before boss.** | ★★ | 7 |
| 80 | **SUPERNOVA (Pulsar):** unstable star `hits=5`; moving gates cycle, and the final hits require arriving the **correct color** during the open window. Timing + sequencing climax. | ★★★ | 11 |

---

### Sector 5 — Singularity (Levels 81–100)
- **Theme:** the galactic core; reality folds; everything at once.
- **Mechanics introduced:** **multi-hit stars** (~L81–83), **switches/gates**
  (~L88–90), then **full-combo** mastery.
- **Difficulty band:** Hard → Expert. `S` 6–8. The game's hardest content.

| Lvl | Idea / beat | Diff | `S` |
|---|---|---|---|
| 81 | **Teach multi-hit** — one star, `hits=2`, light via two passes or two sparks. `introMechanic: multiHit`. | ★★ | 6 |
| 82 | `hits=3` star reachable by a looping bank (one shot, multiple passes). | ★★★ | 6 |
| 83 | Multi-hit + budget pressure (which star deserves your sparks?). | ★★★ | 6 |
| 84 | Multi-hit guarded by a black hole. | ★★★ | 7 |
| 85 | Two multi-hit stars; route to share passes. | ★★★ | 7 |
| 86 | Challenge: multi-hit + color lock. | ★★★ | 7 |
| 87 | Multi-hit + portal looping (elegant repeated passes). | ★★★ | 7 |
| 88 | **Teach switch/gate** — hit switch to open the lane to the star. `introMechanic: switch`. | ★★ | 6 |
| 89 | Switch opens one gate, closes another (state trade). | ★★★ | 6 |
| 90 | Two switches, ordered (latching state machine). | ★★★ | 7 |
| 91 | Switch → mover sync (open gate during the window). | ★★★ | 7 |
| 92 | Switch + multi-hit (open lane, then chip the star). | ★★★ | 7 |
| 93 | Challenge: switch + color + portal. | ★★★ | 7 |
| 94 | Switch reshapes board mid-attempt; plan the order. | ★★★ | 8 |
| 95 | Challenge: everything-but-supernova gauntlet #1. | ★★★ | 8 |
| 96 | Full-combo: well + hole + portal + mover + color. | ★★★ | 8 |
| 97 | Challenge: 3-star demands a near-perfect route. | ★★★ | 8 |
| 98 | The "designer's masterpiece" — elegant solution hidden in chaos. | ★★★ | 8 |
| 99 | **Calm before the grand finale.** | ★★ | 8 |
| 100 | **SUPERNOVA (Singularity) — GRAND FINALE:** multi-hit core `hits=6`; switches reshape the board each phase; a cameo of every prior mechanic. On clear: full-screen "galaxy relit" payoff cutscene. | ★★★ | 12 |

---

## 5. Difficulty balancing methodology (telemetry-driven)

We **author by intent, then retune by data.** Levels ship with designer-chosen
`S`/`par3`/positions; analytics + Remote Config close the loop.

**Metrics per level (GA4 / Firebase Analytics):**
- **Fail rate** = fails / attempts (the primary dial).
- **Attempts-to-clear** distribution; **median sparks used**.
- **3★ rate / 2★ rate / 1★ rate** (efficiency-curve health).
- **Quit rate** (level entered → app/level abandoned without clear).
- **Booster usage** & rewarded-ad-on-fail take rate at that level.
- **Time-to-clear** and **rage-restart count**.

**Target bands (retune toward these):**
| Level type | Target fail rate | Target 3★ rate |
|---|---|---|
| Teaching (`tags: teach`) | < 8% | 40–60% |
| Standard | 12–20% | 25–40% |
| Challenge (`tags: challenge`) | 20–30% | 10–20% |
| Supernova finale | 25–35% | 8–15% |

**Red flags & responses:**
- **Fail rate > 45%** or **quit rate spike** ⇒ difficulty wall. Response: nudge
  `S +1`, loosen `par2`, or move/soften an obstacle via Remote Config (no app
  update needed for `remoteOverridable` fields).
- **3★ rate > 70%** on a non-teaching level ⇒ too easy; tighten `par3`.
- **Sudden drop-off at a level** ⇒ candidate for a re-design in the next content
  patch (Remote Config buys time; the real fix is authored).

**Remote Config surface:** a JSON patch keyed by `levelId` may override
`sparks`, `par3`, `par2`, and flagged obstacle params. The client merges the
patch over the bundled asset at load. **A/B testing**: Remote Config conditions
split cohorts to compare two tunings on fail rate & D1 retention before rolling
a winner to 100%. (Physics constants like `BUMP_GAIN`, `MAX_SPEED`, gravity `G`
are also Remote-Config-exposed — `GAME_DESIGN.md` § 12.)

**Cadence:** review the dashboard weekly; ship Remote Config tuning patches as
needed; bundle authored level fixes into regular app updates.

---

## 6. Level authoring / tooling pipeline

Consistent with the locked stack (Flutter + Flame, Hive/assets — `CONCEPT.md`
§ 11). Content cost is a named risk (`CONCEPT.md` § 14), so tooling is built
early.

```
 [1] AUTHOR ──► [2] VALIDATE ──► [3] BUNDLE ──► [4] LOAD ──► [5] LIVE-TUNE
```

1. **Author.** Two supported workflows:
   - **In-app dev level editor** (debug-only Flame overlay): drag elements on a
     real board, playtest instantly, export JSON. Fastest for feel iteration.
   - **Hand/JSON editing** for precise tweaks, with the schema (§ 2) + JSON
     schema file for editor autocompletion/validation.
   Levels live as assets: `assets/levels/sector_<n>/level_<id>.json`, registered
   in `pubspec.yaml`. (Option: a single packed `levels.json` / binary blob for
   faster cold-load; per-file during development for clean diffs.)

2. **Validate** (CI gate — a Dart script / test, run on every PR touching levels):
   - **Schema validation** (types, required fields, ranges, ids unique 1–100).
   - **Geometry sanity:** all elements inside the safe rect; no overlapping
     solid obstacles on the launch node; clearance ≥ `r + R_star + 1` around
     stars; portal `pairId`s matched; switch `targets` resolve to real gates.
   - **Solvability proof:** run the headless deterministic physics sim against
     each `referenceSolution`; assert it clears the level within `par3` sparks
     using **no boosters**. A level without a passing reference solution **fails
     CI** (enforces the fairness pillar mechanically).
   - **Optional auto-solver:** a bounded search (sampling launch vectors) reports
     the *easiest* clearing shot count and whether the level is trivially
     solvable (too easy) — a balancing aid, not a gate.

3. **Bundle.** Validated JSON ships in the app bundle. A content `version` field
   supports migrations; a manifest lists all 100 + event levels.

4. **Load.** At runtime, `LevelRepository` (get_it/injectable) reads the asset,
   deserializes via `freezed`/`json_serializable` into an immutable `Level`
   model, then **merges any Remote Config override** (§ 5) before handing it to
   the Flame game. Player progress (stars/unlocks) is read/written via **Hive**.

5. **Live-tune.** Remote Config patches adjust `remoteOverridable` fields without
   an app update (§ 5). Event/daily levels (`id ≥ 1000`) may be delivered
   entirely via Firestore/Remote Config.

**Daily Challenge & events:** authored with the same schema/tooling; tagged and
delivered via Firestore so they refresh without app updates (`CONCEPT.md` § 8).

---

## 7. Unlock flow & star gating

- **Sequential unlock:** clearing level `N` unlocks `N+1` (`CONCEPT.md` § 6).
  Unlock state persists in Hive; synced to Firestore when online.
- **Sector gating by total stars:** entering a new sector requires a **minimum
  total stars** earned so far, ensuring players engage with mastery (3★ chasing)
  rather than rushing. Suggested thresholds (Remote-Config-tunable):

  | To unlock | Sector | Min total stars required |
  |---|---|---|
  | 21–40 | 2 Nebula | 18 |
  | 41–60 | 3 Void | 45 |
  | 61–80 | 4 Pulsar | 78 |
  | 81–100 | 5 Singularity | 120 |

  (Max possible by end of sector N is `N*20*3`; e.g., 60 by end of Sector 1.
  Thresholds sit well below the max so no player is hard-walled, but a pure
  1★-rusher must replay a few levels for stars — a gentle mastery nudge and a
  retention hook, `GAME_DESIGN.md` § 10.)

- **Level-select map:** a constellation map per sector showing each level node,
  its earned star count (0–3), lock state, and the next-up highlight. Locked
  sectors show the star requirement and current progress ("45 / 45 ⭐").
- **MVP scope:** Sectors 1–3 ship at v1.0 (`CONCEPT.md` § 12); 4–5 follow
  post-MVP. Gating thresholds for 4–5 are present but inert until those sectors
  ship.

---

## 8. QA / playtest checklist (per level)

**Solvability & fairness**
- [ ] Clears with the authored reference solution, **no boosters**, within `par3`.
- [ ] At least one *intuitive* route is discoverable without external hints.
- [ ] No pixel-perfect or frame-perfect requirement; spark radius gives slack.
- [ ] Not accidentally trivial (auto-solver doesn't clear it in a way that
      undermines the intended idea).

**Determinism & physics**
- [ ] Same launch ⇒ same outcome across 10 repeats and across iOS + Android.
- [ ] No tunneling through thin walls at `MAX_SPEED` (swept collision verified).
- [ ] No spark gets permanently trapped (or, if it can loop, the 8 s cap ends it
      cleanly with a fizzle, not a hang).
- [ ] Moving obstacles loop on a stable period; first frame matches every reset.

**Readability**
- [ ] Trajectory preview matches actual flight for the first 2 reflections.
- [ ] All element silhouettes are unambiguous (well vs. black hole distinct;
      portal pairs clearly matched; destructible vs. bedrock walls distinct).
- [ ] Intro level (if `introMechanic` set) isolates the new element and fires the
      one-time tooltip exactly once.

**Layout & safe area**
- [ ] All geometry inside the safe rect; nothing clipped on a 19.5:9 or 4:3
      device; launch node thumb-reachable; HUD never overlaps interactive geometry.
- [ ] Stardust sits on/near the intended elegant route (rewards the good line).

**Balance & feel**
- [ ] `S`, `par3`, `par2` produce the intended 1★/2★/3★ spread in playtests.
- [ ] Difficulty fits the sector's beat-sheet slot (no spike vs. neighbors).
- [ ] Win celebration, hit juice, and audio fire correctly; reduced-motion mode
      still gives clear feedback.

**Telemetry hooks**
- [ ] Level emits attempt/clear/fail/stars/sparks-used/booster events with the
      correct `levelId` for the balancing dashboard (§ 5).
- [ ] `remoteOverridable` fields respond correctly to a test Remote Config patch.

**Sign-off:** a level ships only when Design **and** QA both check off the above
and the CI validator (§ 6) is green.

---

## Implementation note (Sprint 10)

The 100 shipped level files (`assets/levels/sector_XX/level_XXX.json`) were
produced by **`tool/generate_levels.dart`** — a deterministic generator that
follows the sector schedule (§ 6.1) and the sawtooth difficulty curve (star
count, spark slack, element budget, and mechanic palette per sector/phase).
Regenerate with:

```bash
dart run tool/generate_levels.dart
```

These are an **on-curve baseline to be hand-tuned**, not a substitute for
playtesting — each is validated for parse-correctness, in-bounds geometry, and
spark budget by `test/levels_content_test.dart`. As Design hand-authors bespoke
levels, individual JSON files are edited/replaced in place (the loader and
manifest already key off these paths).
