# NovaPlay — Navigation Architecture (Sprint 7)

> How routing is structured in code. Implements the information architecture in
> [`UI_GUIDELINES.md`](UI_GUIDELINES.md) §1 on top of the stack locked in
> [`ARCHITECTURE.md`](ARCHITECTURE.md) §7 (GoRouter). If anything conflicts with
> [`CONCEPT.md`](CONCEPT.md), the Concept Bible wins.

## 1. Model

Navigation uses **GoRouter** with a single **`StatefulShellRoute.indexedStack`**:

- **Hub tabs** live *inside* the shell, each in its own `StatefulShellBranch`
  (independent navigator + preserved scroll/state): **Home · Daily · Shop ·
  Profile**. The shell (`HubShell`) draws the persistent **top HUD**
  (`HubTopBar`) and the **bottom `NavigationBar`** around the active branch.
- **Full-screen leaves** are *top-level* routes (siblings of the shell), pushed
  onto the **root navigator** so they cover the bottom nav: **Settings ·
  Level Select · Gameplay · Gallery (dev)**, plus the **Splash/boot** route.

```
GoRouter (root navigator)
├─ /                       Splash / boot  → redirects to /home
├─ /settings               Settings            (leaf, fade)
├─ /levels/:sectorId       Level Select        (leaf, fade)
├─ /game/:levelId          Gameplay            (leaf, fade, guarded)
├─ /gallery                Design System (dev) (leaf, fade)
└─ StatefulShellRoute.indexedStack  → HubShell
   ├─ branch 0: /home      Home / Galaxy Map
   ├─ branch 1: /daily     Daily
   ├─ branch 2: /shop      Shop
   └─ branch 3: /profile   Profile
```

## 2. Route table

| Path | Name | Screen | Surface |
|---|---|---|---|
| `/` | `splash` | `SplashScreen` (loading veil) | boot |
| `/home` | `home` | `HomeScreen` (galaxy map) | hub tab 0 |
| `/daily` | `daily` | `DailyScreen` | hub tab 1 |
| `/shop` | `shop` | `ShopScreen` | hub tab 2 |
| `/profile` | `profile` | `ProfileScreen` | hub tab 3 |
| `/settings` | `settings` | `SettingsScreen` | leaf |
| `/levels/:sectorId` | `levelSelect` | `LevelSelectScreen` | leaf |
| `/game/:levelId` | `game` | `GameScreen` | leaf (guarded) |
| `/gallery` | `gallery` | `GalleryScreen` | leaf (dev only) |

Paths and typed builders (`Routes.gamePath`, `Routes.levelSelectPath`) are
centralized in `lib/app/router/route_names.dart`. The router is assembled in
`lib/app/router/app_router.dart`.

## 3. Transitions

- **Hub tab switches** — instant (indexed stack); no cross-fade, preserving the
  calm, snappy feel.
- **Leaf pushes** — a 240 ms fade in / 180 ms fade out (`_fadePage`), matching
  the dialog/motion spec in [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) §5. Respects
  Reduced Motion (fade is already the reduced-motion-safe transition).

## 4. Guards

- **Locked-level guard** on `/game/:levelId`: a `redirect` reads
  `continueLevelProvider`; deep links to a not-yet-unlocked level bounce to
  `/home`. The router receives a Riverpod `Ref` (`AppRouter.build(ref)`) so
  guards can read app state. `LevelSelectScreen` also disables locked nodes, so
  the guard is a deep-link safety net.

## 5. Tab behavior

- Re-tapping the **active** tab pops that branch to its root
  (`goBranch(index, initialLocation: index == currentIndex)`).
- The **Daily** tab shows a badge dot when an unclaimed reward/fresh challenge is
  available (stubbed on in Sprint 7).
- The top HUD's coin/stardust badges route to **Shop**; the gear routes to
  **Settings**; the lives pill opens the refill flow (stubbed).

## 6. Analytics

`AnalyticsNavObserver` (a `NavigatorObserver` on the root navigator) emits a
`screen_view` event with the route name on every push/replace/pop, feeding the
funnels in [`ANALYTICS.md`](ANALYTICS.md). It logs through the app-owned
`AnalyticsService` (a no-op until Firebase Analytics is wired in Sprint 17).

## 7. Not yet wired (later sprints)

- First-run **Onboarding** branch from Splash (Sprint 9 tutorial).
- **Pre-Level Loadout** modal between Level Select and Gameplay (Sprint 13).
- **Win / Lose / Pause** overlays within Gameplay (Sprints 8–9).
- **Daily Reward** and **Lives refill** modal sheets (Sprints 13/15).
- Deep-link/`uni_links` handling and Android back-button edge cases (Sprint 18 QA).
