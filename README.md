# NovaPlay 🌌

> A calm-but-clever **cosmic physics puzzle** for mobile. Launch a spark of
> starlight across a constellation and bounce, curve, and ricochet it to **light
> every dim star** before your sparks run out. _Light the constellations._

Built with **Flutter + Flame**. Offline-first, free-to-play. See
[`docs/`](docs/README.md) for the full product, design, and architecture specs —
[`docs/CONCEPT.md`](docs/CONCEPT.md) is the canonical source of truth.

## Status

| Area | State |
|---|---|
| Sprints 0–4 (docs) | ✅ Complete — see [`docs/`](docs/README.md) |
| Sprint 5 (project setup) | ✅ Scaffolded — builds, analyzes clean, tests pass |
| Sprint 6+ (engine, gameplay, content) | ⏳ Next |

## Getting started

```bash
flutter pub get
flutter run -t lib/main_dev.dart --flavor dev   # dev flavor
```

A bare `flutter run` works too (defaults to the dev flavor via `lib/main.dart`).

### Build flavors

Three flavors, each with its own entrypoint and Android applicationId suffix:

| Flavor | Entrypoint | App ID |
|---|---|---|
| dev | `lib/main_dev.dart` | `com.novaplay.novaplay.dev` |
| staging | `lib/main_staging.dart` | `com.novaplay.novaplay.staging` |
| prod | `lib/main_prod.dart` | `com.novaplay.novaplay` |

```bash
flutter run   -t lib/main_staging.dart --flavor staging
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

## Project layout

```
lib/
├─ app/        # composition root: router (GoRouter), theme, env/flavors
├─ core/       # cross-cutting: DI, services, persistence, errors, widgets
├─ game/       # Flame engine (pure game layer, no app/Firebase imports)
└─ features/   # feature-first modules (home, levels, game, settings, …)
assets/
├─ translations/   # easy_localization catalogs
├─ levels/         # handcrafted level JSON + manifest
└─ images/ audio/
docs/          # product & engineering documentation (start at docs/README.md)
```

Full rationale: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Quality gates

```bash
dart format .          # format (CI is --set-exit-if-changed)
flutter analyze        # very_good_analysis (clean)
flutter test           # unit/widget tests
```

CI runs all three plus a dev APK build on every PR — see
[`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Not yet wired (next steps)

- **Firebase** — run `flutterfire configure` per flavor to generate
  `firebase_options.dart` + platform config. See [`SETUP.md`](SETUP.md).
- **AdMob / IAP** — services are stubbed (`StubAdsService`); real integration in
  Sprints 16 & 13.
- **App icon & splash** — config is in `pubspec.yaml`; drop the source PNGs into
  `assets/images/` then run `dart run flutter_launcher_icons` and
  `dart run flutter_native_splash:create`.

## Codegen

`freezed`, `json_serializable`, and `injectable` are set up for upcoming
sprints. When you start using their annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```
