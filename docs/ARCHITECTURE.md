# NovaPlay — Technical Architecture (Canonical)

> **Derives from `CONCEPT.md`** (single source of truth). The tech stack is **locked**
> per `CONCEPT.md` §11. This document designs *around* that stack; it never swaps it.
> Status: **Sprint 4 draft** · Audience: engineering. Companion docs: `ANALYTICS.md`,
> `LEVEL_DESIGN.md`, `MONETIZATION.md`, `PRD.md`, `ROADMAP.md`.

**Locked stack (recap):** Flutter (stable) + Flame · Riverpod · GoRouter ·
get_it + injectable · freezed + json_serializable · Hive (+ shared_preferences for flags) ·
Firebase (Auth, Firestore, Remote Config, Analytics/GA4, Crashlytics, Cloud Messaging,
optional Cloud Functions) · AdMob via `google_mobile_ads` · `in_app_purchase` ·
`easy_localization`.

---

## Table of contents

1. [Architectural overview & principles](#1-architectural-overview--principles)
2. [High-level layered diagram](#2-high-level-layered-diagram)
3. [Folder / project structure](#3-folder--project-structure)
4. [Feature module anatomy](#4-feature-module-anatomy)
5. [State management with Riverpod](#5-state-management-with-riverpod)
6. [Dependency injection (get_it + injectable)](#6-dependency-injection-get_it--injectable)
7. [Navigation (GoRouter)](#7-navigation-gorouter)
8. [Game engine architecture (Flame)](#8-game-engine-architecture-flame)
9. [Data & persistence](#9-data--persistence)
10. [Firebase plan](#10-firebase-plan)
11. [Ad strategy (technical)](#11-ad-strategy-technical)
12. [Analytics plan (technical)](#12-analytics-plan-technical)
13. [Build flavors & environment config](#13-build-flavors--environment-config)
14. [Localization architecture](#14-localization-architecture)
15. [Error handling, logging & crash strategy](#15-error-handling-logging--crash-strategy)
16. [Testing strategy & CI/CD](#16-testing-strategy--cicd)
17. [Key architectural decisions (ADR-style)](#17-key-architectural-decisions-adr-style)
18. [Performance architecture](#18-performance-architecture)

---

## 1. Architectural overview & principles

NovaPlay is a **Flutter** app that embeds a **Flame** game world for the only
real-time, frame-driven surface in the product: the in-level puzzle. Everything
else (home, level select, shop, settings, profile, onboarding, rewards) is plain
Flutter widget UI. The architecture's central job is to keep these two worlds
**cleanly separated** while letting them share a single source of truth for
progress, economy, and tuning.

### 1.1 Guiding principles

- **Clean architecture, pragmatic.** Three logical layers per feature —
  **presentation → domain → data** — with dependencies pointing *inward*
  (presentation depends on domain; data implements domain interfaces; domain
  depends on nothing Flutter/Firebase-specific). We do *not* over-abstract: a
  use case exists when it carries real logic or coordinates repositories, not as
  ceremony around a one-line passthrough.
- **Feature-first.** Code is organized by product feature (`features/game`,
  `features/levels`, `features/economy`, …), not by technical type. Cross-cutting
  primitives live in `core/`.
- **Offline-first (per `CONCEPT.md` §2).** The game is fully playable with no
  network. **Hive is the source of truth at runtime**; Firebase is a *sync &
  config* layer that hydrates and backs up local state. No screen blocks on a
  network call.
- **Engine/app separation.** The Flame layer (`lib/game/`) knows nothing about
  Riverpod, GoRouter, Firebase, or repositories. It receives an immutable
  `LevelDefinition` in and emits domain events/results out. A thin
  **adapter/bridge** (`GameSessionController`) is the *only* seam between Flame
  and Riverpod. This keeps physics deterministic, unit-testable headless, and
  unaffected by app concerns.
- **Determinism.** Physics uses a **fixed timestep** and integer/rational-friendly
  math so a given level + input sequence always produces the same outcome —
  required for "readable physics" (`CONCEPT.md` §2, §14) and replay/validation.
- **Testability by construction.** Domain and game logic have no Flutter imports
  where avoidable, so they run in pure Dart unit tests. DI lets us swap fakes.
- **Immutability.** All models/state are `freezed`. State transitions are explicit
  and copy-based; no hidden mutation across layers (the Flame world is the one
  controlled mutable island, by design).

### 1.2 What lives where (one-paragraph mental model)

> Widgets render and dispatch intents → **Riverpod providers** hold app/UI state and
> call **use cases** → use cases orchestrate **repositories** (domain interfaces) →
> repository *implementations* in the data layer talk to **Hive / Firebase / assets**.
> The **Flame `NovaGame`** is mounted by a single widget (`GameView`) and driven by a
> `GameSessionController`; it reports results back up through a provider. Tuning values
> (gravity strength, ad frequency, life cap) flow from **Remote Config → core service →
> providers → both UI and the game world.**

---

## 2. High-level layered diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION (Flutter)                            │
│  Screens & widgets: Home · LevelSelect · GameView · Shop · Settings · Profile  │
│  · Onboarding · Rewards/Daily.   Consume providers, dispatch intents.          │
│                                                                                │
│        ┌──────────────────────────────────────────────────────────────┐       │
│        │   GameView (Flutter widget)  ──mounts──▶  FLAME GAME WORLD     │       │
│        │   ┌────────────────────────────────────────────────────────┐  │       │
│        │   │  NovaGame (FlameGame)                                   │  │       │
│        │   │   World ▸ SparkComponent · StarComponent · WallComp.   │  │       │
│        │   │   · BumperComp · GravityWellComp · BlackHoleComp        │  │       │
│        │   │   · PortalComp · MovingObstacleComp · trajectory preview │  │       │
│        │   │   Systems: PhysicsSystem (fixed dt) · CollisionSystem   │  │       │
│        │   │   · CameraComponent · ParticlePool                      │  │       │
│        │   └────────────────────────────────────────────────────────┘  │       │
│        │        ▲  LevelDefinition (in)        GameEvent/Result (out) ▼  │       │
│        └────────│──────────────────────────────────────────│──────────┘       │
│                 │              GameSessionController         │  (the ONLY bridge)│
└─────────────────│────────────────────────────────────────│──┘─────────────────┘
                  │ watch / read                            │ emits
┌─────────────────▼─────────────────────────────────────────▼────────────────────┐
│                       APPLICATION / STATE  (Riverpod)                           │
│  Providers & Notifiers: gameSessionProvider · levelsProvider · progressProvider │
│  · economyProvider · livesProvider · settingsProvider · adProvider · authProvider│
│  Hold app/UI state, call use cases, expose immutable state to presentation.      │
└─────────────────────────────────┬────────────────────────────────────────────────┘
                                  │ calls
┌─────────────────────────────────▼────────────────────────────────────────────────┐
│                                 DOMAIN                                            │
│  Entities (freezed): LevelDefinition · LevelProgress · Wallet · Lives · PlayerProfile│
│  Use cases: PlayLevel · ApplyLevelResult · SpendCoins · ConsumeLife · RefillLives │
│  · UnlockNextLevel · ClaimDailyReward · GrantRewardedAd                            │
│  Repository INTERFACES (abstract): ProgressRepository · EconomyRepository · …      │
│  Pure Dart. No Flutter / Firebase / Hive imports.                                 │
└─────────────────────────────────┬────────────────────────────────────────────────┘
                                  │ implemented by
┌─────────────────────────────────▼────────────────────────────────────────────────┐
│                                  DATA                                             │
│  Repository IMPLEMENTATIONS · DTOs (json_serializable) ◀──map──▶ Entities          │
│  Data sources: HiveLocalSource · FirestoreRemoteSource · LevelAssetSource (JSON)   │
│  Sync engine: CloudSyncService (conflict resolution).                             │
└─────────────────────────────────┬────────────────────────────────────────────────┘
                                  │ uses
┌─────────────────────────────────▼────────────────────────────────────────────────┐
│                            CORE / SERVICES (cross-cutting)                        │
│  DI (get_it+injectable) · RemoteConfigService · AnalyticsService · CrashReporter  │
│  · AdService · IapService · MessagingService · AudioService · HapticsService      │
│  · ConnectivityService · Logger · Result/Failure types · Theme · Localization     │
└──────────────────────────────────────────────────────────────────────────────────┘
```

**Where the Flame world sits:** it is *inside* the presentation layer (mounted by a
widget) but is a self-contained sub-system. It never reaches down into domain/data
directly. The `GameSessionController` (a Riverpod-managed object) feeds it a
`LevelDefinition` and listens to its `GameResult`; persistence and economy happen
*after* the game emits a result, via use cases — keeping physics pure.

---

## 3. Folder / project structure

```
novaplay/
├─ android/ ios/                         # native shells, flavor configs, google-services
├─ assets/
│  ├─ levels/                            # 100 level JSONs: sector_01/level_001.json …
│  │  └─ levels_manifest.json            # index + checksums + schema version
│  ├─ images/  audio/  fonts/
│  └─ translations/                      # easy_localization: en.json, … (see §14)
├─ test/  integration_test/              # mirror lib/ structure (see §16)
├─ pubspec.yaml
└─ lib/
   ├─ main_dev.dart  main_staging.dart  main_prod.dart   # flavor entrypoints (§13)
   ├─ bootstrap.dart                     # shared async init: DI, Hive, Firebase, RC, ads
   │
   ├─ app/                               # App-level wiring (no business logic)
   │  ├─ app.dart                        # NovaApp: MaterialApp.router + EasyLocalization
   │  ├─ router/                         # GoRouter config, routes, guards (§7)
   │  ├─ theme/                          # ThemeData, colors, text styles, "lofi space" tokens
   │  └─ env/                            # AppEnvironment (flavor), compile-time config
   │
   ├─ core/                              # Cross-cutting; depends on nothing feature-specific
   │  ├─ di/                             # injectable config + module registrations (§6)
   │  ├─ error/                          # Failure hierarchy, Result<T>, exception mappers (§15)
   │  ├─ result/                         # Result/Either-style type
   │  ├─ logging/                        # Logger facade (→ Crashlytics in prod)
   │  ├─ services/                       # RemoteConfig, Analytics, Crash, Ads, Iap,
   │  │                                  #   Messaging, Audio, Haptics, Connectivity
   │  ├─ persistence/                    # Hive setup, box names, type adapters registry (§9)
   │  ├─ network/                        # Firebase init helpers, connectivity guards
   │  ├─ constants/                      # box keys, RC keys, route names, ad placements
   │  ├─ extensions/  utils/             # small helpers
   │  └─ widgets/                        # shared UI atoms (buttons, dialogs, currency chip)
   │
   ├─ game/                              # FLAME ENGINE — pure game layer (no Riverpod/Firebase)
   │  ├─ nova_game.dart                  # NovaGame extends FlameGame (entrypoint)
   │  ├─ world/                          # NovaWorld, layer ordering, bounds
   │  ├─ components/                     # SparkComponent, StarComponent, WallComponent,
   │  │                                  #   BumperComponent, GravityWellComponent,
   │  │                                  #   BlackHoleComponent, PortalComponent,
   │  │                                  #   MovingObstacleComponent, TrajectoryPreview
   │  ├─ systems/                        # PhysicsSystem, CollisionSystem, SpawnSystem
   │  ├─ physics/                        # vectors, integrator, collision math (pure Dart)
   │  ├─ input/                          # DragAimController (drag-to-aim)
   │  ├─ render/                         # ParticlePool, glow/trail effects, palettes
   │  ├─ session/                        # GameSessionController bridge, GameResult, GameEvent
   │  └─ model/                          # in-engine value types (LevelDefinition consumed here)
   │
   └─ features/                          # FEATURE-FIRST modules (each: data/domain/presentation)
      ├─ game/                           # in-level orchestration (wraps the Flame world)
      │  ├─ domain/                      # PlayLevel, ApplyLevelResult use cases; GameState entity
      │  ├─ data/                        # session persistence (in-flight save/resume)
      │  └─ presentation/                # GameScreen, GameView (mounts NovaGame), HUD, overlays
      ├─ levels/                         # level catalog, select, unlock, ratings
      │  ├─ domain/                      # LevelDefinition, LevelProgress, repo interfaces, use cases
      │  ├─ data/                        # LevelAssetSource (JSON), ProgressRepository impl
      │  └─ presentation/                # LevelSelectScreen, SectorMap, level node widgets
      ├─ home/                           # main menu / sector overview
      ├─ economy/                        # coins, stardust, lives, wallet, transactions
      ├─ rewards/                        # daily reward, login streak, chests (post-MVP scaffolds)
      ├─ shop/                           # IAP store, remove-ads, packs, cosmetics
      ├─ settings/                       # audio/haptics/locale/account, privacy, restore purchases
      ├─ profile/                        # XP/player level, achievements, stats
      └─ onboarding/                     # first-run tutorial, consent, anonymous auth
```

**Folder responsibilities (annotated):**

| Folder | Responsibility |
|---|---|
| `app/` | Composition root for the *Flutter* app: router, theme, env, `MaterialApp.router`. No game/business logic. |
| `core/di/` | `get_it`/`injectable` graph and hand-written module bindings (Hive boxes, Firebase singletons). |
| `core/error|result/` | `Failure` hierarchy + `Result<T>` used across domain/data boundaries (§15). |
| `core/services/` | Singletons wrapping third-party SDKs behind app-owned interfaces (Analytics, Ads, RC, …). |
| `core/persistence/` | Hive initialization, adapter registration, box-name constants (§9). |
| `game/` | The Flame engine. **No app imports.** Deterministic, headless-testable. |
| `game/session/` | The single bridge between Flame and the app (`GameSessionController`). |
| `features/<x>/domain/` | Entities, repository *interfaces*, use cases. Pure Dart. |
| `features/<x>/data/` | Repository *implementations*, DTOs, data sources (Hive/Firestore/assets). |
| `features/<x>/presentation/` | Screens, widgets, Riverpod providers scoped to the feature. |
| `assets/levels/` | The 100 handcrafted level JSONs + manifest (loading/validation in §9). |
| `assets/translations/` | `easy_localization` JSON catalogs (§14). |

---

## 4. Feature module anatomy

Every feature follows the same three-folder shape. Dependencies point inward:
`presentation → domain ← data`. The domain layer never imports Flutter, Hive, or
Firebase.

### 4.1 Generic shape

```
features/<feature>/
├─ domain/
│  ├─ entities/            # freezed immutable models
│  ├─ repositories/        # abstract interfaces (the contract)
│  └─ usecases/            # one class per orchestration; callable
├─ data/
│  ├─ dtos/                # json_serializable DTOs ⇄ entity mappers
│  ├─ datasources/         # local (Hive) + remote (Firestore/assets)
│  └─ repositories/        # implements domain/repositories
└─ presentation/
   ├─ providers/           # Riverpod providers/notifiers
   ├─ screens/             # routable pages
   └─ widgets/             # feature-local widgets
```

### 4.2 Example — `levels` feature

```
features/levels/
├─ domain/
│  ├─ entities/
│  │  ├─ level_definition.dart      # full board spec consumed by Flame (freezed)
│  │  ├─ level_progress.dart        # cleared?, stars(0..3), bestSparksUsed, stardust
│  │  └─ sector.dart                # 5 sectors × 20 levels metadata
│  ├─ repositories/
│  │  ├─ level_catalog_repository.dart   # abstract: getLevel(id), listSector(s)
│  │  └─ progress_repository.dart        # abstract: read/write LevelProgress
│  └─ usecases/
│     ├─ load_level.dart            # fetch + validate LevelDefinition
│     ├─ unlock_next_level.dart     # sequential unlock (CONCEPT §6)
│     └─ compute_star_rating.dart   # sparksUsed/stardust → stars
├─ data/
│  ├─ dtos/level_definition_dto.dart     # json_serializable mirror of the asset JSON
│  ├─ datasources/
│  │  ├─ level_asset_source.dart    # reads assets/levels/**, checks manifest checksum
│  │  └─ progress_hive_source.dart  # Hive box 'progress'
│  └─ repositories/
│     ├─ level_catalog_repository_impl.dart
│     └─ progress_repository_impl.dart    # Hive write-through + queue cloud sync
└─ presentation/
   ├─ providers/levels_provider.dart      # sector/level lists, lock state
   ├─ screens/level_select_screen.dart
   └─ widgets/level_node.dart             # locked/unlocked/3-star node
```

### 4.3 Example — `game` feature (wraps the Flame world)

The `game` *feature* is the orchestration around the `lib/game/` *engine*. It is
the only feature that touches `lib/game/`.

```
features/game/
├─ domain/
│  ├─ entities/
│  │  ├─ game_state.dart            # freezed: status, sparksLeft, starsLit, stardust
│  │  └─ game_result.dart           # win/lose, sparksUsed, stardustCollected, stars
│  └─ usecases/
│     ├─ start_level.dart           # builds LevelDefinition for the engine
│     └─ apply_level_result.dart    # persist progress, spend life, grant coins, unlock
├─ data/
│  └─ session_snapshot_source.dart  # Hive box 'session' — in-level resume (§8.10)
└─ presentation/
   ├─ providers/game_session_provider.dart   # owns GameSessionController
   ├─ screens/game_screen.dart               # Scaffold + GameView + HUD overlays
   └─ widgets/
      ├─ game_view.dart                       # GameWidget<NovaGame> host
      ├─ game_hud.dart                         # sparks left, stars, pause, boosters
      └─ overlays/  (pause, win, lose, stuck-offer rewarded-ad)
```

**Flow for one play session:**
1. Router pushes `GameScreen(levelId)`.
2. `gameSessionProvider` runs `StartLevel` → `LoadLevel` → returns a
   `LevelDefinition`, builds `GameSessionController` + `NovaGame`.
3. `GameView` mounts the `NovaGame` via Flame's `GameWidget`.
4. Player drags-to-aim and launches; engine runs deterministic physics; HUD reflects
   `GameState` streamed from the controller.
5. On win/lose the engine emits `GameResult` → `ApplyLevelResult` use case persists
   progress, updates economy/lives, unlocks next level, fires analytics, decides ad.

---

## 5. State management with Riverpod

### 5.1 Conventions

- **Riverpod 2.x with code generation** (`@riverpod` / `riverpod_generator`). Generated
  providers give compile-time safety and consistent naming.
- **App state vs game state are separated:**
  - **App state** (progress, wallet, lives, settings, auth, ads) lives in Riverpod
    notifiers and is the durable, sync-backed truth.
  - **Game state** (per-frame physics, component positions) lives **inside the Flame
    world** and is *not* in Riverpod — pushing 60 fps mutations through Riverpod would
    thrash rebuilds. Only the *coarse* `GameState` (sparks left, stars lit, status) is
    surfaced to Riverpod via a `ValueNotifier`/stream from the `GameSessionController`,
    so the HUD rebuilds at human cadence, not frame cadence.
- **Provider taxonomy:**
  - `Provider` — pure DI lookups / derived read-only values (e.g. `remoteConfigProvider`).
  - `FutureProvider` / `StreamProvider` — async loads (level lists, auth state, RC fetch).
  - `NotifierProvider` / `AsyncNotifierProvider` — mutable feature state with logic
    (`EconomyNotifier`, `ProgressNotifier`, `LivesNotifier`).
- **No business logic in widgets.** Widgets `ref.watch` state and call notifier methods
  (which call use cases). Use cases are resolved from `get_it` inside notifiers.
- **Scoping & lifetime:** global app state is `keepAlive`; per-screen ephemeral state is
  `autoDispose`. The game session provider is `autoDispose` (tears down the Flame world
  on leaving the level) but persists a resume snapshot first.

### 5.2 Example provider sketches

```dart
// economy: durable wallet, write-through to Hive + queued cloud sync
@riverpod
class EconomyNotifier extends _$EconomyNotifier {
  @override
  Wallet build() => getIt<EconomyRepository>().readWalletSync();

  Future<void> earnCoins(int amount, {required String source}) async {
    final updated = await getIt<EarnCoins>()(amount: amount, source: source);
    state = updated;                           // immutable freezed Wallet
    getIt<AnalyticsService>().log(CurrencyEarned(amount, source));
  }

  Future<bool> spendCoins(int amount, {required String sink}) async {
    final result = await getIt<SpendCoins>()(amount: amount, sink: sink);
    return result.fold((_) => false, (wallet) { state = wallet; return true; });
  }
}
```

```dart
// lives: regenerating energy gate (1 / 20 min, cap from Remote Config)
@riverpod
class LivesNotifier extends _$LivesNotifier {
  @override
  Lives build() {
    final cap = ref.watch(remoteConfigProvider).livesCap;        // tuning from RC
    return getIt<RefillLivesOverTime>().current(cap: cap);
  }
  // ConsumeLife / RefillLives use cases handle timestamps + clamping.
}
```

```dart
// game session: owns the engine bridge; surfaces coarse GameState to the HUD
@riverpod
class GameSession extends _$GameSession {
  @override
  GameState build(int levelId) {
    final level = getIt<StartLevel>()(levelId);
    final controller = GameSessionController(level: level);
    ref.onDispose(controller.dispose);
    controller.results.listen(_onResult);                        // win/lose
    _controller = controller;
    return GameState.initial(level);
  }
  late final GameSessionController _controller;
  NovaGame get game => _controller.game;

  void onCoarseUpdate(GameState s) => state = s;                 // HUD cadence
  Future<void> _onResult(GameResult r) =>
      getIt<ApplyLevelResult>()(levelId, r);
}
```

```dart
// derived: is a level unlocked? combines progress + sector gate
@riverpod
bool isLevelUnlocked(IsLevelUnlockedRef ref, int levelId) {
  final progress = ref.watch(progressNotifierProvider);
  return getIt<UnlockNextLevel>().isUnlocked(levelId, progress);
}
```

---

## 6. Dependency injection (get_it + injectable)

### 6.1 Strategy

- `injectable` generates the `get_it` graph from annotations; a single
  `configureDependencies()` call in `bootstrap.dart` wires everything.
- **Layered registration via annotations:**
  - `@LazySingleton(as: Abstract)` for repositories & services (one instance, created on
    first use) — register against the **domain interface**, not the impl.
  - `@injectable` for use cases (cheap, created per resolution).
  - `@module` for third-party objects we don't own (Hive boxes, Firebase instances,
    `FirebaseAuth`, `GoogleMobileAds`, Dio if used).
- **Flavor/environment scoping** uses injectable environments: `dev`, `staging`, `prod`.
  Example: a `LoggingAnalyticsService` in `dev`, the real `FirebaseAnalyticsService` in
  `prod`, registered behind the same `AnalyticsService` interface.
- **Riverpod ↔ get_it boundary:** get_it owns *infrastructure* singletons (services,
  repositories, use cases). Riverpod owns *stateful UI/app state*. Notifiers pull use
  cases via `getIt<…>()`. We do **not** duplicate stateful objects in both.
- **Scopes:** mostly app-wide singletons. A short-lived scope is pushed for an
  authenticated session if any per-user singleton needs the uid; in practice user data is
  passed as parameters, so we avoid scope juggling.

### 6.2 Example

```dart
// core/di/injection.dart
final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true, asExtension: false)
Future<void> configureDependencies(String env) async =>
    getIt.init(environment: env);            // env: dev | staging | prod

// core/di/register_module.dart — things we don't construct ourselves
@module
abstract class RegisterModule {
  @preResolve @lazySingleton
  Future<Box<ProgressDto>> progressBox() => Hive.openBox<ProgressDto>('progress');

  @lazySingleton FirebaseAuth get auth => FirebaseAuth.instance;
  @lazySingleton FirebaseFirestore get firestore => FirebaseFirestore.instance;
  @lazySingleton FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;
}

// data — bound to the domain interface, env-aware
@LazySingleton(as: ProgressRepository, env: ['dev', 'staging', 'prod'])
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._local, this._sync);
  // ...
}

@injectable
class UnlockNextLevel {
  UnlockNextLevel(this._progress);     // resolved use case
}
```

---

## 7. Navigation (GoRouter)

### 7.1 Conventions

- One `GoRouter` configured in `app/router/`. Route *names* are constants in
  `core/constants/routes.dart`. We navigate by name (`context.goNamed`) to avoid stringly
  typed paths.
- **Redirects/guards** are pure functions reading Riverpod state via a `ProviderContainer`
  reference (or `ref` through `refreshListenable`), so navigation reacts to auth/onboarding
  changes.
- **Shell route** wraps the main tabbed area (Home / Levels / Shop / Profile) so the bottom
  nav persists; `GameScreen` is pushed **on top** (full-screen, no bottom bar) to maximize
  the play surface and let us lock orientation/immersive mode while playing.

### 7.2 Route table

| Name | Path | Screen | Notes / guard |
|---|---|---|---|
| `splash` | `/` | Splash/bootstrap | Runs init, then redirects to onboarding or home. |
| `onboarding` | `/onboarding` | Onboarding + consent | Shown until `onboardingComplete` flag set. Guards entry to rest of app. |
| `home` | `/home` | Home (sector overview) | Shell tab. |
| `levels` | `/levels` | Level select | Shell tab. |
| `sector` | `/levels/sector/:sectorId` | Sector map | Param `sectorId` 1–5. |
| `game` | `/game/:levelId` | GameScreen | **Guard: level must be unlocked** (and lives > 0 to start). Pushed over shell. |
| `gameResult` | `/game/:levelId/result` | Win/Lose summary | Reached via in-game overlay or route. |
| `shop` | `/shop` | Shop / IAP | Shell tab. |
| `dailyReward` | `/rewards/daily` | Daily reward / streak | Deep-link target from push. |
| `settings` | `/settings` | Settings | Pushed. |
| `profile` | `/profile` | Profile / stats / achievements | Shell tab. |
| `account` | `/settings/account` | Link account (anon → Google/Apple) | Nested under settings. |

### 7.3 Guards (sketch)

```dart
String? _redirect(BuildContext ctx, GoRouterState state) {
  final c = ProviderScope.containerOf(ctx);
  if (!c.read(onboardingDoneProvider) && state.uri.path != '/onboarding') {
    return '/onboarding';
  }
  if (state.matchedLocation.startsWith('/game/')) {
    final levelId = int.parse(state.pathParameters['levelId']!);
    if (!c.read(isLevelUnlockedProvider(levelId))) return '/levels';   // locked
    if (c.read(livesNotifierProvider).current <= 0) return '/levels';  // out of lives
  }
  return null;
}
```

### 7.4 Deep links

- Push notifications (Cloud Messaging) and external links resolve to named routes:
  `novaplay://rewards/daily`, `novaplay://game/42`, `novaplay://shop`. Universal
  Links (iOS) / App Links (Android) map `https://novaplay.app/...` to the same names.
  All deep links pass through the same redirect guards (a locked level link bounces to
  `/levels`).

---

## 8. Game engine architecture (Flame)

The engine is the heart of "readable physics" (`CONCEPT.md` §2, §14). It is a
**self-contained Flame module** under `lib/game/` with no app dependencies.

### 8.1 Game loop & structure

- `NovaGame extends FlameGame` is the root. It holds a single `NovaWorld` (a Flame
  `World` under a `CameraComponent`). The world owns all gameplay components.
- Flame drives `update(dt)`; we **do not** run physics on the raw `dt`. We accumulate
  real time and step physics in a **fixed timestep** (§8.8) for determinism.

### 8.2 Component model

Each field element from `CONCEPT.md` §5 maps to a Flame `Component`:

| Component | Role | Physics interaction |
|---|---|---|
| `SparkComponent` | The launched Nova spark (the only dynamic body). | Integrated each fixed step; carries position/velocity, optional color. |
| `StarComponent` | Dim star; lights on spark touch (multi-hit/color-lock variants). | Trigger collider; no reflection. |
| `WallComponent` / asteroid | Solid reflective surface. | Reflective bounce (line/segment normals). |
| `BumperComponent` | Bouncy pad; adds energy. | Reflect + velocity gain factor. |
| `GravityWellComponent` | Curves the path toward it. | Applies radial acceleration within radius. |
| `BlackHoleComponent` | Sink hazard; ends the shot. | Inside event-radius ⇒ spark consumed. |
| `PortalComponent` (paired) | Teleports spark to its exit keeping momentum. | Translate position to paired exit, preserve velocity vector. |
| `MovingObstacleComponent` | Drifts on a timed deterministic path. | Position is a pure function of `levelTime` (so it stays deterministic). |
| `TrajectoryPreview` | Dotted aim preview before launch. | Re-runs the integrator headlessly for N steps to draw the path. |

Components are **data-driven** from the `LevelDefinition`: a `LevelBuilder` reads the
spec and instantiates the components into the world.

### 8.3 Physics approach — **recommendation: custom lightweight deterministic physics (NOT Forge2D)**

**Decision: build a small custom 2D physics core, not Forge2D/Box2D.** Justification:

- **Determinism & readability** are explicit pillars. Box2D's solver is iterative and
  tuned for general rigid-body realism; reproducing identical results across devices and
  guaranteeing "the player can predict roughly where the spark goes" is harder, not easier.
- Our world is **one dynamic body** (the spark) against mostly **static colliders** plus a
  few simple force fields (gravity wells) and special triggers (portals, sinks, stars).
  This is a *particle-vs-static-geometry* problem, not a full rigid-body simulation. Forge2D
  is heavy overkill and adds a large dependency surface, GC pressure, and tuning friction.
- A custom core lets us use **circle vs. line-segment / circle vs. circle** analytic
  collision with exact reflection — clean, fast, and easy to unit-test headlessly.
- We keep math **pure Dart in `game/physics/`** (vectors, integrator, collision), so it
  runs in plain unit tests with no Flame/Flutter context and no platform variance.

**Integrator:** semi-implicit (symplectic) Euler at a fixed `dt` (e.g. 1/120 s) gives stable,
predictable trajectories for gravity wells without RK4 cost. Substep on fast frames.

### 8.4 Input handling (drag-to-aim)

- `DragAimController` (a Flame input mixin on the game, e.g. `DragCallbacks`) captures
  `onDragStart/Update/End`. Drag vector → launch direction + power (clamped). During drag,
  `TrajectoryPreview` re-runs the integrator headlessly to render the dotted path
  (with bounces, up to a step/length budget). On release, the spark is spawned with the
  computed velocity and the shot begins. Boosters like "Guided Line" simply extend the
  preview step budget.

### 8.5 Camera

- A `CameraComponent` frames the level. Levels are authored in a virtual coordinate space;
  the camera fits the board to the portrait viewport (letterboxing the safe area). Mild
  follow/zoom only for "Supernova" finale set-pieces (`CONCEPT.md` §5). No free pan in MVP.

### 8.6 Rendering layers

Painter's order via component `priority`:
1. Background (starfield, nebula gradient) — lowest.
2. Static field (walls, bumpers, portals, wells).
3. Stars (dim/lit states).
4. Spark + trail.
5. Particles / FX (the "calm spectacle" payoff).
6. In-world UI hints (aim line). HUD is *Flutter* overlay, above the `GameWidget`.

### 8.7 Collision detection strategy

- **Not** Flame's general collision callbacks for the hot path. The spark is tested
  analytically each fixed substep against nearby colliders:
  - **Broad phase:** a simple uniform grid / spatial hash over static colliders (built once
    per level) keeps checks O(local).
  - **Narrow phase:** circle–segment and circle–circle tests; on hit, compute the exact
    contact and reflect velocity about the surface normal (bumper applies a gain factor).
  - **Triggers** (stars, portals, black holes) are overlap tests resolved after movement.
- **Continuous collision (anti-tunneling):** because the spark is fast and the timestep
  fixed, we sweep the spark's segment for this substep against colliders (segment–segment /
  segment–circle) so it can't pass through thin walls.

### 8.8 Fixed timestep

```dart
@override
void update(double dt) {
  _accumulator += dt.clamp(0, _maxFrame);          // avoid spiral-of-death
  while (_accumulator >= _fixedDt) {
    physics.step(_fixedDt, world);                 // deterministic substep
    _levelTime += _fixedDt;                        // drives moving obstacles
    _accumulator -= _fixedDt;
  }
  // rendering interpolation factor = _accumulator / _fixedDt (optional smoothing)
  super.update(dt);
}
```

Moving obstacles read `_levelTime` (a pure function of accumulated fixed steps), so replays
and the trajectory preview are deterministic.

### 8.9 Pause / resume

- `NovaGame.pauseEngine()/resumeEngine()` stops the loop for system-level pause; in-app
  pause overlay is a Flutter overlay that calls `pauseEngine()` and freezes `_levelTime`.
  App lifecycle (`AppLifecycleState.paused`) auto-pauses and persists a snapshot (§8.10).

### 8.10 Save / load of in-level state

- A level is **purely a function of**: `levelId` + the **sequence of shots** (launch
  vectors) + boosters used. So the canonical in-level save is the **deterministic input
  log** plus current `GameState` (sparks left, stars lit, stardust). On resume we either
  restore the lightweight snapshot directly or replay the input log to reconstruct state.
- Snapshot is written to Hive box `session` on pause/background and cleared on level
  exit/complete. Because physics is deterministic, replay yields an identical board — this
  is also the foundation for "Rewind" (undo last shot = drop the last input and replay).

---

## 9. Data & persistence

### 9.1 Local — Hive boxes (runtime source of truth, offline-first)

| Box | Contents | Notes |
|---|---|---|
| `progress` | `LevelProgress` per level (cleared, stars, bestSparksUsed, stardust), highest unlocked, sector gates. | Write-through; queued for cloud sync. |
| `settings` | audio/haptics, locale, notifications opt-in, reduced-motion. | Mirrors a few flags into `shared_preferences` for pre-init reads. |
| `economy` | `Wallet` (coins, stardust), `Lives` (count + lastRefillTs), XP/player level, owned boosters, ownership flags (remove-ads). | Sync-critical; conflict-resolved (§9.4). |
| `session` | In-level resume snapshot / input log (§8.10). | Transient; cleared on level end. |
| `levelCache` | Parsed/validated level definitions + manifest version. | Optional cache to skip re-parsing asset JSON. |

- Typed boxes use `freezed` entities mapped via `json_serializable` DTOs and Hive type
  adapters. Box names and keys are constants in `core/constants/`. `shared_preferences`
  holds only boot-time flags (current flavor selected locale, onboarding-complete,
  consent state) that must be readable before Hive opens.

### 9.2 Level assets pipeline (100 levels)

- **Storage:** levels ship as **JSON in `assets/levels/sector_XX/level_NNN.json`**, plus
  `assets/levels/levels_manifest.json` listing every level id, sector, file path, schema
  version, and a content checksum.
- **Schema:** each level JSON declares `schemaVersion`, board bounds, a list of typed
  elements (`{type: "wall", a:[x,y], b:[x,y]}`, `{type:"star", pos:[x,y], hits:1, color:null}`,
  gravity wells, portals (paired ids), moving-obstacle paths), `sparkCount`, `stardust`
  positions, and star-rating thresholds.
- **Loading:** `LevelAssetSource` loads via `rootBundle`, deserializes into
  `LevelDefinitionDto` (json_serializable), maps to the `LevelDefinition` entity, and
  optionally caches in `levelCache`.
- **Validation:** at load (and in a CI test, §16) we validate: schema version supported,
  required fields present, portals paired, coordinates within bounds, level is *solvable
  sanity* (at least non-degenerate — full solvability is a design-time check in level
  tooling per `CONCEPT.md` §14). A checksum mismatch vs the manifest fails fast in dev/CI.
- This keeps content **data-driven and reviewable**, and lets Remote Config later point to
  alternate/event level packs without an app update.

### 9.3 Cloud save sync strategy

- **Hive is authoritative at runtime; Firestore is the durable backup/sync.** On meaningful
  changes (level cleared, purchase, currency change) we write Hive immediately and enqueue a
  debounced cloud push. On launch/auth and on regaining connectivity, we pull the cloud doc
  and merge.
- `CloudSyncService` runs the merge off the UI path; nothing in gameplay blocks on it.

### 9.4 Conflict resolution

- Each sync-critical aggregate carries a **monotonic `version`** and `updatedAt`.
- **Progress** merges **field-wise, max-wins**: highest unlocked level, max stars per level,
  min bestSparksUsed — progress never regresses (covers the common "played offline on two
  devices" case).
- **Economy** is reconciled by **server-authoritative ledger** intent: client sends
  *deltas* (earned/spent events) that the server (Firestore transaction or Cloud Function,
  §10) applies idempotently keyed by event id, rather than overwriting balances — this
  prevents the "lost coins" and double-spend problems and resists trivial tampering.
- **Settings** use last-write-wins by `updatedAt` (low stakes).
- If offline, deltas queue locally and flush on reconnect; idempotency keys make replays safe.

---

## 10. Firebase plan

### 10.1 Auth

- **Anonymous sign-in on first run** (no friction; supports offline-first identity for cloud
  save). Optional **account linking** to Google / Apple from Settings → Account, which
  upgrades the anonymous uid in place (preserving progress). Apple Sign-In is mandatory on
  iOS if any third-party login is offered.

### 10.2 Firestore data model

```
users/{uid}
  profile      : { displayName, avatarId, playerLevel, xp, createdAt, locale, platform }
  flags        : { removeAds: bool, consent: {...}, onboardingDone: bool }
  updatedAt, version

users/{uid}/progress/{levelId}
  cleared: bool, stars: 0..3, bestSparksUsed: int, stardust: int, updatedAt

users/{uid}/wallet/state
  coins: int, stardust: int, lives: int, lastLifeRefillAt, version

users/{uid}/ledger/{eventId}           # append-only economy deltas (idempotent)
  type: 'earn'|'spend', currency, amount, source/sink, ts

users/{uid}/inventory/{itemId}         # boosters, cosmetics, ownership

leaderboards/{boardId}/entries/{uid}   # post-MVP: stars or event score
  score, displayName, updatedAt

events/{eventId}                       # server-driven event config (read-only to clients)
  type, startsAt, endsAt, levelPack, rewards

config/levelPacks/{packId}             # optional remote/event level definitions
```

- **Document-per-aggregate** keeps reads cheap and write contention low. `progress` is a
  subcollection (per-level docs) so a single level update is a small write. The append-only
  **ledger** subcollection is the backbone of economy conflict resolution (§9.4).

### 10.3 Remote Config keys (tuning, flags, A/B, ad frequency)

| Key | Purpose |
|---|---|
| `lives_cap`, `life_refill_minutes` | Energy economy tuning (`CONCEPT.md` §7). |
| `coins_per_clear`, `coins_per_star` | Reward tuning. |
| `gravity_well_strength`, `bumper_gain`, `spark_max_power` | Physics feel tuning (read by the engine bridge). |
| `interstitial_min_level_gap`, `interstitial_cooldown_sec` | Ad frequency caps (`CONCEPT.md` §9; §11 here). |
| `rewarded_offers_enabled`, `rewarded_cooldown_sec` | Rewarded gating. |
| `ff_daily_challenge`, `ff_events`, `ff_leaderboards`, `ff_shop_cosmetics` | Feature flags (MVP vs post-MVP per `CONCEPT.md` §12). |
| `ab_onboarding_variant`, `ab_paywall_variant` | A/B experiments. |
| `min_supported_build` | Force-update gate. |

- Fetched on launch with sensible **in-app defaults** (offline-first: the app runs fully on
  defaults). Values surface through `RemoteConfigService` → `remoteConfigProvider` → both UI
  and the game bridge. Activation strategy: fetch-and-activate on launch, throttled.

### 10.4 Analytics, Crashlytics, Messaging, Functions

- **Analytics (GA4):** see §12 and `ANALYTICS.md`.
- **Crashlytics:** all uncaught Flutter + isolate errors routed in (§15); custom keys for
  current level/flavor/uid-hash.
- **Cloud Messaging:** daily-challenge/streak reminders, event launches; routes to deep
  links (§7.4). Opt-in respected.
- **Cloud Functions (optional):** apply economy ledger deltas server-side idempotently,
  validate leaderboard scores, send scheduled push for daily challenge, server-side IAP
  receipt validation. Kept optional for MVP (client + security rules suffice initially).

### 10.5 Security rules approach

- Default **deny all**; `users/{uid}/**` readable/writable **only when `request.auth.uid ==
  uid`**. Validate types/ranges (coins/stars non-negative, stars ≤ 3) in rules.
- `events/**` and `config/**` are **read-only** to clients (written by admins/Functions).
- Leaderboard writes constrained (own entry only) and ideally finalized via a Function to
  deter score spoofing. Economy integrity ultimately leans on the ledger + Functions for
  anything that matters competitively; pure single-player currency is best-effort client-side
  with rule range checks.

---

## 11. Ad strategy (technical)

### 11.1 Integration

- `google_mobile_ads`, wrapped by an app-owned `AdService` (interface in `core/services/`,
  impl in data/core). Initialized in `bootstrap.dart` **after** consent (§11.4).
- Two formats for MVP (`CONCEPT.md` §9): **rewarded** (primary) and **interstitial**
  (between levels). Banners are not in MVP.

### 11.2 Ad unit management & test/prod IDs per flavor

- Ad unit IDs are **per platform × per flavor**, never hard-coded inline. They live in env
  config (`app/env/`) keyed by `AppEnvironment`:
  - `dev` / `staging` → **Google test ad unit IDs** (always, to avoid invalid-traffic risk).
  - `prod` → real AdMob unit IDs (injected via `--dart-define`/flavor config, not committed).
- `AdPlacement` enum (`rewardedExtraSpark`, `rewardedDoubleCoins`, `rewardedLifeRefill`,
  `interstitialLevelEnd`) maps to the resolved unit id.

### 11.3 Loading & caching

- **Preload + cache** one instance per active placement. On dispose of a shown ad, immediately
  request the next so an ad is ready when the player needs it ("extra spark on fail" must be
  instant). A small state machine per placement: `idle → loading → ready → showing → idle`,
  with backoff on load failure and a max-retry cap.
- Rewarded callbacks resolve a `Future<RewardOutcome>` so use cases (`GrantRewardedAd`) can
  `await` the reward and then apply it (extra spark, double coins, life refill) transactionally.

### 11.4 Frequency capping via Remote Config

- Interstitials obey `interstitial_min_level_gap` + `interstitial_cooldown_sec` and the
  `CONCEPT.md` §9 rules: **never mid-level, never in the first sessions**, cooldown enforced.
  `AdFrequencyController` tracks "levels since last interstitial" and a cooldown timestamp in
  Hive; values come from Remote Config so we can tune without a release.
- Remove-Ads IAP / consent state can disable interstitials entirely at the gate.

### 11.5 Consent (UMP / GDPR)

- Google **User Messaging Platform (UMP)** consent flow runs at first launch (in onboarding,
  before ad init). We gather consent, store the state (and a TCF string), and only initialize
  ads / personalized ads per the result. ATT (App Tracking Transparency) prompt on iOS is
  sequenced with UMP. No ad request fires before consent resolves.

---

## 12. Analytics plan (technical)

- **Single facade `AnalyticsService`** (interface in `core/services/`) so call sites never
  touch the Firebase SDK directly. Events are **typed** (`sealed class AnalyticsEvent` with
  `freezed` variants) carrying `name` + params; a `GA4AnalyticsService` maps them to
  `FirebaseAnalytics.logEvent`. `dev` flavor uses a logging impl.
- **Taxonomy approach:** snake_case event names grouped by domain — `level_*`
  (`level_start`, `level_complete`, `level_fail`, `level_restart`), `economy_*`
  (`currency_earn`, `currency_spend`), `ad_*` (`ad_impression`, `ad_reward_granted`),
  `iap_*`, `progression_*`, `retention_*` (`daily_reward_claim`). Common params:
  `level_id`, `sector`, `sparks_used`, `stars`, `source/sink`, `flavor`, `ab_variant`.
  **`ANALYTICS.md` is the authoritative full event list**; this section defines only the
  conventions and emission points.
- **Where emitted:** events are logged from **use cases / notifiers**, *not* widgets — so a
  given action emits exactly once regardless of UI rebuilds. The Flame engine emits no
  analytics directly; the `game` feature logs on result.
- **Funnels:** install → onboarding_complete → first_level_start → first_level_complete →
  D1 return; and ad/IAP funnels. GA4 + BigQuery export for cohort/funnel analysis;
  Crashlytics for stability funnels (crash-free sessions, `CONCEPT.md` §13).

---

## 13. Build flavors & environment config

### 13.1 Flavors

Three flavors: **dev**, **staging**, **prod**, with separate entrypoints
(`main_dev.dart` / `main_staging.dart` / `main_prod.dart`) each calling
`bootstrap(AppEnvironment.dev|staging|prod)`.

| Concern | dev | staging | prod |
|---|---|---|---|
| Firebase project | `novaplay-dev` | `novaplay-stg` | `novaplay-prod` |
| `google-services.json` / `GoogleService-Info.plist` | per-flavor under `android/app/src/<flavor>/` and iOS config sets | | |
| AdMob IDs | Google test IDs | test IDs | real IDs |
| App id suffix | `.dev` | `.stg` | (none) |
| Analytics | local log impl | real (debug view) | real |
| Logging | verbose | info | warn/error → Crashlytics |

- Android: `productFlavors` in Gradle. iOS: schemes + xcconfig per flavor.

### 13.2 Env config & secrets

- Non-secret config (flavor name, base URLs, default RC) compiled via `AppEnvironment`.
- **Secrets** (real AdMob ids, API keys not already in the plist/json) are passed via
  `--dart-define-from-file=env/prod.json` at build time and injected through CI secrets;
  never committed. `firebase_options.dart` is generated per flavor by FlutterFire CLI.

### 13.3 SDK targets (recommendation)

- **Android:** `minSdkVersion 24` (Android 7.0) — covers ~the casual mass market while
  allowing modern AdMob/Firebase and good GPU; `targetSdk`/`compileSdk` = latest stable
  required by Play (currently 35).
- **iOS:** **deployment target 13.0** (Firebase/`google_mobile_ads` floor); target latest
  SDK. Portrait-only, one-handed (`CONCEPT.md` §2).

---

## 14. Localization architecture (easy_localization)

- `easy_localization` with **JSON catalogs** in `assets/translations/` (`en.json` at
  launch, scaffolding for more per `CONCEPT.md` §11/§12). `EasyLocalization` wraps the app
  in `app.dart`; `supportedLocales` and `fallbackLocale: Locale('en')`.
- **Key structure:** namespaced, dotted, feature-aligned to mirror the module layout:

```json
{
  "home":     { "play": "Play", "daily_challenge": "Daily Challenge" },
  "levels":   { "sector": "Sector {id}", "locked": "Locked", "stars": "{count} ★" },
  "game":     { "sparks_left": "{count} sparks", "win_title": "Constellation lit!",
                "lose_title": "Out of sparks" },
  "economy":  { "coins": "Coins", "lives_full": "Lives full" },
  "shop":     { "remove_ads": "Remove Ads", "restore": "Restore Purchases" },
  "settings": { "audio": "Audio", "haptics": "Haptics", "language": "Language" }
}
```

- Asset loading: declared under `flutter/assets` in `pubspec.yaml`; lazy-loaded by locale.
  Pluralization/args via easy_localization's `plural()` / named-arg interpolation. No raw
  user-facing strings in code — lint/CI check guards against hard-coded strings.

---

## 15. Error handling, logging & crash strategy

- **Result over exceptions across boundaries.** Repositories return `Result<T>` (a
  `freezed` `Either`-like `Success`/`Failure`). Failures are a typed hierarchy
  (`NetworkFailure`, `CacheFailure`, `AuthFailure`, `AdFailure`, `IapFailure`,
  `LevelDataFailure`). Use cases map low-level exceptions to `Failure`s; UI maps `Failure`s
  to friendly, localized messages (and a "retry"/"continue offline" affordance — never a
  blocking error in offline-first flows).
- **Logging facade** `Logger` (in `core/logging/`): in `dev` prints; in `prod` routes
  warn/error to Crashlytics as non-fatal logs with breadcrumbs.
- **Crash capture:** `bootstrap.dart` sets `FlutterError.onError` →
  `Crashlytics.recordFlutterFatalError`, and `PlatformDispatcher.onError` for async/isolate
  errors. Custom keys: flavor, current route, level id, anonymized uid. We run the app in a
  `runZonedGuarded` zone so nothing escapes uncaught.
- **Game engine errors** are contained: a thrown error in a component is caught at the
  session boundary, reported as non-fatal, and the level is safely aborted to the level-select
  rather than crashing the app.
- **Crash-free target ≥ 99.5%** (`CONCEPT.md` §13) is a release gate watched in Crashlytics.

---

## 16. Testing strategy & CI/CD

### 16.1 Test pyramid

| Layer | Scope | Tooling |
|---|---|---|
| **Unit** | Domain (use cases, star-rating, unlock logic), **physics core** (integrator, collision, reflection determinism), repositories with fakes, conflict-resolution merge. | `flutter_test`, `mocktail`. |
| **Flame game-logic tests** | Headless engine: feed a `LevelDefinition` + a scripted input log, assert deterministic `GameResult` (same input → same outcome), portal/gravity/bounce behavior, win/lose conditions, anti-tunneling. | `flame_test`, pure-Dart physics tests (no Flutter binding needed). |
| **Widget** | Screens & HUD render and react to provider state (locked level, lives empty, win/lose overlays). | `flutter_test`, Riverpod `ProviderScope` overrides. |
| **Golden** | Key visual surfaces (level node states, HUD, win screen) for regression. | `golden_toolkit`/`alchemist`. |
| **Integration / E2E** | Boot → onboarding → play level 1 → clear → unlock level 2 → economy update, on device/emulator. | `integration_test`. |
| **Asset validation** | Every level JSON parses, matches schema, manifest checksums, portals paired, in-bounds. | Dart test over `assets/levels/**`. |

- **Determinism is a first-class test:** the same `(levelId, inputLog)` must always yield
  the same `GameResult` across runs — guards the core pillar and enables replay/Rewind.
- DI is overridable in tests (injectable test env / get_it resets); Riverpod providers are
  overridden in `ProviderScope`.

### 16.2 CI/CD (GitHub Actions)

```
on: [pull_request, push to main]
jobs:
  analyze:   flutter pub get → dart format --set-exit-if-changed → flutter analyze
             → build_runner (freezed/injectable/riverpod/json) check (no dirty diff)
  test:      flutter test --coverage  (unit + widget + golden + physics + asset-validation)
  build:     matrix [dev, staging, prod] × [android, ios]
             android: flutter build appbundle --flavor <f> -t lib/main_<f>.dart
                      --dart-define-from-file=env/<f>.json
             ios:     flutter build ipa --flavor <f> -t lib/main_<f>.dart (no-codesign on PR)
  (main/tag) distribute: upload to Firebase App Distribution (staging) / store tracks (prod)
```

- Secrets (`google-services`, signing, AdMob ids, env files) come from GitHub Encrypted
  Secrets. Coverage threshold and `flutter analyze` are required PR checks. Generated code
  is verified up-to-date (build_runner produces no diff).

---

## 17. Key architectural decisions (ADR-style)

| # | Decision | Rationale | Trade-off accepted |
|---|---|---|---|
| ADR-1 | **Custom lightweight deterministic physics**, not Forge2D. | Single dynamic body vs static geometry; determinism & readability are pillars; smaller, testable, no platform variance. | We build/maintain collision math ourselves; no general rigid-body realism (we don't need it). |
| ADR-2 | **Flame world isolated from app** via one `GameSessionController` bridge. | Keeps physics pure/headless-testable; app concerns (Firebase, Riverpod) never leak into the loop. | A little boilerplate marshalling state in/out. |
| ADR-3 | **Hive authoritative at runtime; Firebase as sync/config.** | Offline-first pillar (`CONCEPT.md` §2); no screen blocks on network. | Need explicit conflict resolution (§9.4). |
| ADR-4 | **Economy via append-only ledger + idempotent deltas.** | Prevents lost/double-spent currency on multi-device; sync-safe. | More moving parts than overwriting a balance. |
| ADR-5 | **Levels as data-driven JSON assets + manifest.** | Reviewable content, validation in CI, future remote/event packs without app update. | Need a schema + validation discipline. |
| ADR-6 | **Game state stays in Flame, not Riverpod; only coarse state surfaced.** | 60 fps mutations must not trigger widget rebuilds. | Two notions of "state"; bridge keeps them in sync at human cadence. |
| ADR-7 | **Riverpod (codegen) for app state; get_it/injectable for infra.** | Clear split: stateful UI vs singletons/use cases; both locked by stack. | Two DI-ish systems; boundary rule (§6.1) must be respected. |
| ADR-8 | **Fixed timestep loop** decoupled from frame `dt`. | Deterministic physics & replay (Rewind, validation, tests). | Slightly more loop logic; interpolation for smooth render. |
| ADR-9 | **Remote Config drives tuning, ad caps, feature flags, A/B.** | Tune economy/ads/rollout without releases (`CONCEPT.md` §9, §12). | Must ship safe in-app defaults for offline. |
| ADR-10 | **Three flavors with separate Firebase projects + test ad ids in non-prod.** | Safe testing, no invalid traffic, clean data separation. | Extra config surface to maintain. |

---

## 18. Performance architecture

Target: **60 FPS on mid-tier devices**, fast cold start, low memory/battery
(`CONCEPT.md` §11, §13).

- **Object pooling** for the hot, churny objects: spark-trail segments and success-payoff
  particles (`game/render/ParticlePool`). Pools pre-allocate and recycle components so we
  avoid per-frame allocation and GC stalls during the "calm spectacle" bursts. The spark and
  field components are few and long-lived (one level), so they aren't pooled.
- **No per-frame allocation in the loop:** reuse `Vector2` scratch instances in physics/
  collision; avoid closures/`List` allocation inside `update`. The fixed-step integrator and
  spatial hash are written allocation-free on the hot path.
- **Broad-phase spatial hash** keeps collision O(local) even on busy boards (§8.7).
- **Trajectory preview budget:** the headless re-simulation for the aim line is capped by
  step/length budget so dragging never tanks the frame.
- **Rendering:** batch via component priority layers; pre-bake static layers (starfield/
  nebula) where possible; use simple shaders/glow sparingly; cap particle counts (and respect
  a "reduced motion" setting for accessibility/perf).
- **Asset compression:** textures as compressed atlases (WebP/ETC2/ASTC as appropriate);
  audio as compressed (OGG/AAC) and short SFX preloaded; fonts subset; level JSON is tiny.
- **Cold start:** defer non-critical init (ads after consent, RC fetch, cloud sync) off the
  first frame; `bootstrap.dart` only blocks on Hive + Firebase core; show the level select
  fast and hydrate the rest asynchronously.
- **Memory/battery:** pause the engine when backgrounded or on overlays (§8.9); free the
  `NovaGame` on leaving a level (`autoDispose` session provider); avoid timers running while
  paused.
- **Frame budget discipline:** 16.6 ms/frame. Physics substeps are bounded
  (`_maxFrame` clamp prevents spiral-of-death); profile with the Flutter/Flame performance
  overlay in dev builds and treat jank as a release-blocking regression.

---

*End of `ARCHITECTURE.md` (Sprint 4). Conforms to the locked stack in `CONCEPT.md` §11; any
future change to the stack must update `CONCEPT.md` first, then this document.*
