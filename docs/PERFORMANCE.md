# PERFORMANCE.md — NovaPlay Performance Budget & Optimizations

> Sprint 18 deliverable. Targets, the optimizations applied, and how to profile.
> Companion to [ARCHITECTURE.md](ARCHITECTURE.md) §8 (engine) and
> [QA_PLAN.md](QA_PLAN.md) (device matrix).

## 1. Targets

| Metric | Target | Floor (low-end) |
|---|---|---|
| Frame rate (gameplay) | 60 FPS | ≥ 30 FPS, no sustained jank |
| Frame build + raster | < 16 ms (60 Hz) / < 8 ms (120 Hz) | < 33 ms |
| Cold start to first frame | < 2.0 s | < 3.5 s |
| Cold start to interactive (Home) | < 2.5 s | < 4.0 s |
| Idle memory (Home) | < 120 MB | < 180 MB |
| Gameplay memory | < 200 MB | < 260 MB |
| Jank-free shot | 0 dropped frames during a launched spark | ≤ 1 |
| Battery (10 min session) | ≤ 4% on a mid-range device | — |

Reference low-end device: ~2019 mid-range Android (4 GB RAM, Mali/Adreno 6xx).

## 2. Rendering — 60 FPS

The Flame world repaints every frame. The golden rule: **`render()` and
`update()` must not allocate.** Allocations in the hot loop create GC pressure
that shows up as periodic jank.

- **Cached `Paint` objects.** Every component that draws now holds its `Paint`
  as a `static final` (shared, fixed-color: walls, gravity wells, black holes,
  portals, stars, hint guide) or a reused instance field whose color is mutated
  per draw (spark trail, trajectory preview, victory bloom). Previously each
  `render()` allocated one `Paint` per draw call — dozens of allocations per
  frame across a populated level. See `lib/game/components/*` and
  `lib/game/effects/*`.
- **Fixed-timestep physics.** The simulation runs at a fixed 1/120 s step
  decoupled from render (ARCHITECTURE.md §8.3), so frame-rate dips never change
  game behaviour and the integrator does bounded work per frame.
- **`RepaintBoundary` around the game.** The `GameWidget` is wrapped in a
  `RepaintBoundary` (`game_screen.dart`) so its continuous repaints don't
  invalidate the HUD/overlay layer above it.
- **Starfield is static.** `SpaceBackground`'s painter returns
  `shouldRepaint == false`; the star field is computed once, not per frame.
- **Reduced motion.** When the player enables reduced motion, the one heavy
  spectacle (victory bloom) and particle bursts are skipped entirely
  (UI_GUIDELINES.md §3.6).

## 3. Memory

- **Self-removing effects.** Particle bursts and the bloom call
  `removeFromParent()` when finished — no retained effect components.
- **Single dynamic body.** Exactly one `SparkBody` is simulated; colliders are
  immutable value objects built once per level load.
- **No image cache pressure.** The art is vector/`Canvas`-drawn; there are no
  decoded bitmaps held in `ImageCache` during gameplay.
- **Bounded undo stack.** Rewind snapshots are lightweight value objects, capped
  by the shots taken in a single level.

## 4. Battery

- **Lives timer runs only while regenerating.** The 1-second lives countdown
  (`LivesNotifier`) starts when a life is spent and **cancels itself the moment
  lives hit the cap** — no perpetual per-second wakeup when the player is full.
- **No render when paused.** Pausing routes to an overlay; the engine is not
  advanced while the pause sheet is up.
- **Deferred SDK warm-up** (below) keeps the CPU off non-essential work during
  the launch spike.

## 5. Startup

`bootstrap()` does the minimum before the first frame:

1. `WidgetsFlutterBinding.ensureInitialized()` + environment.
2. Localization + Hive (required to render the first screen).
3. `configureDependencies()` — registers singletons, then **blocks only on the
   critical path** (`CrashReporter`, `RemoteConfigService`) via `Future.wait`,
   and **warms up the rest in the background** (`AdsService`, `AudioService`,
   `NotificationService`) with `unawaited(...)`. Each background init is guarded
   independently so a slow/failing SDK can neither block startup nor cancel its
   peers.

Net effect: the ad SDK load, audio preload, and notification-channel setup no
longer sit on the cold-start critical path.

## 6. Asset compression

- **Level JSON is minified.** `tool/generate_levels.dart` emits compact
  (whitespace-free) JSON for the 100 bundled levels + manifest — **~45% smaller**
  (79.3 KB → 43.7 KB of JSON) with identical parse results. Regenerate with
  `dart run tool/generate_levels.dart`; never hand-edit the output.
- **Font tree-shaking.** `flutter build` tree-shakes `MaterialIcons` to the
  glyphs actually used (visible in build logs as a 99%+ reduction).
- **Audio placeholders.** The shipped SFX are silent WAV placeholders; replace
  with compressed OGG before release (see `tool/generate_placeholder_audio.dart`
  and RELEASE_PLAN.md).

## 7. How to profile

```bash
# Frame timings + raster — run a profile build on a real device:
flutter run --profile
#   then open DevTools → Performance, toggle "Track Widget Builds",
#   record a level, look for frames over the 16 ms line.

# Startup trace:
flutter run --profile --trace-startup
#   reads build/start_up_info.json (timeToFirstFrameMicros, etc.)

# Memory:
#   DevTools → Memory → record while playing; watch for a sawtooth that
#   doesn't return to baseline (a leak).

# Raster cost overlay (on device):
#   add showPerformanceOverlay: true to the MaterialApp in debug to eyeball
#   the UI + raster thread bars.
```

**Checklist before a release build**
- [ ] No `Paint()` / `Object` allocation inside any `render()` / `update()`.
- [ ] Profile-build a populated late-game level (sector 5) at a locked 60 FPS.
- [ ] Cold start to Home under target on the reference low-end device.
- [ ] Memory returns to baseline after exiting a level (no leak).
- [ ] `flutter build` shows font tree-shaking and no oversized assets.
