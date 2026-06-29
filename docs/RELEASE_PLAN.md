# NovaPlay — Release Plan (Sprints 21 & 22)

> Scope: **Sprint 21 — Store Assets & metadata** and **Sprint 22 — Release**.
> Derived from [`CONCEPT.md`](./CONCEPT.md) (canonical). Platforms: Android (Google Play)
> + iOS (App Store). Stack: Flutter + Flame, Firebase, AdMob, `in_app_purchase`.
> Feeds from [`QA_PLAN.md`](./QA_PLAN.md) (beta exit) and points forward to
> [`ROADMAP.md`](./ROADMAP.md).

> **Implemented in Sprint 21:** localized store metadata in
> [`store/metadata/`](../store/metadata) (en/es/ar, Play + App Store, fastlane
> layout — rationale in [`STORE_LISTING.md`](./STORE_LISTING.md)); Android release
> signing wired in `android/app/build.gradle.kts` via gitignored
> `android/key.properties` (template: `android/key.properties.example`); iOS
> privacy manifest `ios/Runner/PrivacyInfo.xcprivacy` + [`PRIVACY.md`](./PRIVACY.md)
> (Data Safety / nutrition labels); release CI in `.github/workflows/release.yml`
> (signed AAB + iOS verify + web); a smart in-app review prompt (`ReviewGate` +
> `ReviewService`). Screenshot capture spec: [`store/screenshots/`](../store/screenshots).

---

## 1. Release Overview & Versioning

NovaPlay v1.0 ships the MVP: core launch-and-light mechanic, sectors 1–3 (≥ 60 levels),
star ratings, save/load + cloud sync, coins + lives + 3 core boosters, daily reward, AdMob
rewarded + interstitial, analytics + Crashlytics, audio + haptics, EN.

**Versioning — SemVer + build number** (Flutter `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`):

| Part | Meaning | Example |
|---|---|---|
| MAJOR | Breaking / milestone (v1 launch, v2) | `1` |
| MINOR | New content/features (level packs, events) | `0` |
| PATCH | Bug-fix / hotfix | `0` |
| BUILD | Monotonic build number (== Android `versionCode`, iOS `CFBundleVersion`) | `+100` |

- **Launch target:** `1.0.0+100`. Build number **always increments**, never reused.
- **Release train:** code freeze → RC build → internal → closed/TestFlight → staged
  production. Hotfixes branch from the release tag as `1.0.x`.
- Android `versionCode` and iOS `CFBundleVersion` derive from the same `+BUILD`.

---

## 2. Pre-Release Checklist

### Legal & compliance

- [ ] **Privacy Policy** published at a stable URL (covers Firebase Analytics, Crashlytics, AdMob, IAP, cloud save).
- [ ] **Terms of Service / EULA** published and linked in-app + store listing.
- [ ] **Google Play Data Safety** form completed (data collected/shared, security practices).
- [ ] **Apple App Privacy ("nutrition labels")** completed in App Store Connect.
- [ ] **Ad consent** — GDPR/UMP (Google User Messaging Platform) consent flow; iOS **ATT** prompt before tracking; consent state honored by AdMob.
- [ ] **Children/age** — not directed at children; appropriate age gate / target-age set; ads families-policy compliant if applicable.
- [ ] **IAP terms** + restore-purchases available; clear pricing.

### Technical

- [ ] **Android signing** — Play **App Signing** enrolled; upload key secured; keystore backed up.
- [ ] **iOS signing** — distribution certificate + App Store provisioning profile valid.
- [ ] **R8 / ProGuard** shrinking + **obfuscation** enabled for release; keep-rules verified (Firebase, AdMob, IAP, freezed/json reflection-free).
- [ ] **Flutter obfuscation** — `--obfuscate --split-debug-info=...`; symbols archived.
- [ ] **Crashlytics symbols** — Android mapping/NDK symbols + Flutter split-debug-info uploaded; **iOS dSYMs** uploaded.
- [ ] **Release config** — production Firebase project, prod AdMob unit IDs (not test), Remote Config defaults sane, logging stripped.
- [ ] **Min versions** — Android API 28 min, iOS 15 min (per QA matrix / `ARCHITECTURE.md`).
- [ ] **Permissions** audited (only what's needed); manifests/Info.plist usage strings present.
- [ ] **Build artifacts** — Android **AAB** (per flavor), iOS archive validated.
- [ ] **Store metadata** — listings, screenshots, icon, ratings, contact + support URL.
- [ ] **Smoke test** of the exact production-signed build on real devices.

---

## 3. Store Assets Requirements (Sprint 21)

### App icon

| Store | Spec |
|---|---|
| Android | 512×512 PNG (32-bit, no alpha for Play listing); adaptive icon (foreground + background) in app |
| iOS | 1024×1024 PNG, no alpha, no rounded corners (Apple applies mask) |

### Screenshots

| Store | Required sizes | Count |
|---|---|---|
| Google Play | Phone (min 2, up to 8); 16:9 or 9:16, 1080px+ on a side; optional 7" & 10" tablet | 4–8 phone |
| App Store | 6.7" (e.g. iPhone 15 Pro Max) **and** 6.5"; plus 5.5" if supporting older; iPad 12.9" if iPad-enabled | 3–10 per size |

Screenshot set (both stores): (1) hero — spark mid-flight lighting a constellation,
(2) level-select sector map, (3) win/3-star payoff, (4) booster in action (Slow-Mo),
(5) sector variety (gravity well / portal), each with a short benefit caption.

### Other assets

| Asset | Where | Spec |
|---|---|---|
| **Feature graphic** | Google Play | 1024×500 PNG/JPG |
| **Promo / preview video** | Play (YouTube link) | 15–30 s gameplay |
| **App preview video** | App Store | 15–30 s, per device size, captured on device |
| **Promo text** | App Store | ≤ 170 chars, updatable without review |

### Sample store copy (NovaPlay)

**Short description (Google Play, ≤ 80 chars):**
> Light every star. A calm, clever cosmic physics puzzle. Aim, bounce, shine.

**App Store subtitle (≤ 30 chars):**
> Light the constellations

**Long description (sample):**
> **Light the constellations.**
>
> The galaxy has gone dark. You are the Nova — a wandering spark of starlight. Drag to aim,
> release to launch, and bounce, curve, and ricochet your spark to relight every dim star
> before your sparks run out.
>
> NovaPlay is a calm-but-clever cosmic physics puzzle. Quiet board, joyful payoff. One more
> try is always one tap away.
>
> ✦ **Readable physics** — see the trajectory, predict the bounce, make the shot.
> ✦ **Handcrafted levels** — across glowing sectors, each adding one clever new idea.
> ✦ **Bounce, curve, teleport** — walls, bumpers, gravity wells, black holes, and portals.
> ✦ **Boosters** — Guided Line, Slow-Mo, Extra Spark for those "so close" moments.
> ✦ **Earn your stars** — clear levels efficiently to master all three stars.
> ✦ **Play anywhere** — fully playable offline; optional cloud save keeps your progress.
> ✦ **Lofi space vibes** — minimal art, soothing sound, satisfying light.
>
> Free to play, fair by design — every level is solvable without spending. Relax. Aim.
> Light the sky.

**Keywords / ASO (App Store keyword field, comma-sep; mirror in Play via description):**
> physics puzzle, space puzzle, brain game, relaxing game, casual puzzle, trajectory,
> stars, constellation, offline puzzle, aim and shoot, logic, cosmic

**Localized listings note:** Launch listing is **EN** only (matching MVP locale scope).
Store-listing strings and screenshot captions are structured for later localization; add
locales post-MVP alongside in-app `easy_localization` locales (see `ROADMAP.md`).

---

## 4. Android Release Plan

| Step | Detail |
|---|---|
| **Console setup** | Create app in Google Play Console; set default language EN, category Games > Puzzle |
| **App signing** | Enroll Play App Signing; upload key stored in CI secrets; keystore backed up offline |
| **Build** | `flutter build appbundle --release --flavor prod --obfuscate --split-debug-info=build/symbols` → AAB per flavor |
| **Data Safety** | Declare Analytics, Crashlytics, AdMob (device/ad IDs), account/cloud-save data; security & deletion path |
| **Content rating** | Complete **IARC** questionnaire (puzzle, contains ads, in-app purchases, no violence) → expect Everyone / PEGI 3 |
| **Ads / IAP** | Declare "Contains ads"; configure managed products (Remove Ads, coin/stardust packs) |
| **Release tracks** | **Internal → Closed → Open (optional) → Production** |
| **Staged rollout** | Production rollout at **5% → 20% → 50% → 100%**, advancing only if crash-free/ANR/ratings hold; halt/rollback otherwise |
| **Pre-launch report** | Use Play's automated pre-launch device testing for early crash/perf signal |

---

## 5. iOS Release Plan

| Step | Detail |
|---|---|
| **App Store Connect** | Create app record, bundle ID, category Games > Puzzle; set EN as primary |
| **TestFlight** | Internal testers (no review) → external testers (Beta App Review) — already exercised in Sprint 20 beta |
| **App Privacy** | Nutrition labels: identifiers (ads), usage/diagnostics (Analytics/Crashlytics), purchases; tracking declared if ATT used |
| **IAP** | Configure products (Remove Ads etc.) in App Store Connect; submit with first build |
| **Review-guideline risks** | **Ads** — disclose third-party ads, ATT prompt copy; **IAP** — must use StoreKit, restore available; **Lucky Wheel/chests (post-MVP)** — disclose odds for any "loot/lucky" mechanic (Guideline 3.1.1) — N/A at v1.0 MVP but flagged for v2; **metadata** — accurate screenshots, no mention of other platforms |
| **Submission** | Upload via Xcode/Transporter or fastlane; attach demo account if reviewers need progress; review notes explaining ads/IAP/offline |
| **Phased release** | Enable **App Store phased release** (7-day automatic rollout) for production; can pause if issues arise |

---

## 6. Build & CI/CD Release Pipeline (GitHub Actions + fastlane — outline)

```
Trigger: tag push  v1.0.0  (release train) / manual dispatch
─────────────────────────────────────────────────────────────
1. setup        checkout · flutter stable · cache pub · restore secrets (keystore, certs, service accounts)
2. quality gate flutter analyze · format check · flutter test (unit + widget + flame)
3. integration  smoke E2E (patrol) on emulator/simulator
4. build:android flutter build appbundle --release --flavor prod --obfuscate --split-debug-info
                 → sign (Play App Signing) → upload Crashlytics mapping/symbols
5. build:ios     flutter build ipa --release --obfuscate --split-debug-info
                 → codesign (match) → upload dSYMs to Crashlytics
6. deliver       fastlane supply  → Play internal/closed track (AAB + metadata + screenshots)
                 fastlane pilot/deliver → TestFlight / App Store (IPA + metadata)
7. promote       manual approval → staged production rollout (Play %) / phased release (iOS)
8. notify        post build #, version, dashboards link to release channel
```

- Secrets in GitHub encrypted secrets / environment protection rules; production deploy
  requires manual approval (environment gate).
- **fastlane** lanes: `beta_android`, `beta_ios`, `release_android`, `release_ios`,
  `upload_symbols`.

---

## 7. Launch-Day Monitoring

| Watch | Tool | Threshold / action |
|---|---|---|
| Crash-free sessions/users | **Crashlytics** | < 99.5% sessions → pause rollout, hotfix |
| New/velocity-alert crashes | Crashlytics velocity alerts | Any S1 crash → halt + hotfix |
| **ANR** (Android) | Play Console vitals | Above bad-behaviour threshold → halt |
| Funnels & retention | **Firebase Analytics (GA4)** dashboards | Tutorial completion, level drop-off, D1 |
| Performance | Firebase Performance | Startup + FPS traces vs targets |
| Ratings & reviews | Play Console / App Store Connect | Sudden rating drop or recurring bug report → triage |
| Ad/IAP health | AdMob + Play/ASC reports | Fill/reward errors, purchase failures |
| **Rollback/hotfix plan** | see §9 | Documented, rehearsed |

A **launch war-room** (defined window post-go-live) watches the above; on-call owner for
S1. Staged rollout % is the primary safety valve — do not advance until metrics are green.

---

## 8. Post-Launch (Sprint 23)

| Item | Plan |
|---|---|
| **KPI review cadence** | Daily for launch week, then weekly: D1/D7/D30 retention, crash-free, ARPDAU, IAP conversion, rewarded opt-in (targets in `MONETIZATION.md` / `ANALYTICS.md`) |
| **Retention analysis** | Cohort retention curves; level drop-off heatmap; difficulty/economy tuning via **Remote Config** (no rebuild) |
| **Content update pipeline** | Add sectors 4–5 (levels 61–100), events/seasonal, leaderboards via the level-tooling pipeline; ship as MINOR releases on the release train |
| **v2 roadmap** | Tracked in [`ROADMAP.md`](./ROADMAP.md) — deferred features: sectors 4–5, leaderboards, events, Lucky Wheel/chests, color-lock & switch mechanics, more locales, IAP cosmetics |
| **Feedback loop** | Reviews + in-app feedback → backlog → prioritized into next release train |

---

## 9. Risk & Rollback Procedures

| Risk | Mitigation | Rollback |
|---|---|---|
| Critical crash post-launch | Staged rollout, Crashlytics velocity alerts | **Halt rollout** in Play (production %); iOS **pause phased release**; ship hotfix `1.0.x` |
| Bad release already at 100% | — | Play: roll out a previous good build as a higher build number (no down-version); expedited hotfix |
| Remote-config-driven issue (economy/ad cadence) | Server-side tunable | Revert Remote Config values instantly — no app update needed |
| IAP delivery failures | Test accounts pre-launch, server validation | Pause product if needed; reconcile entitlements; refund guidance |
| Ad policy/consent violation | UMP + ATT verified pre-launch | Disable ad unit via Remote Config flag; fix consent |
| Cloud-sync data loss | Backups, conflict-merge rules (QA §5 EC-15) | Server-side restore from snapshot; hotfix merge logic |
| Store rejection (iOS review) | Pre-empt guideline risks (§5), demo account, review notes | Address feedback, resubmit; keep Android launch decoupled |

**Hotfix flow:** branch from release tag → minimal fix → full quality gate (no skips) →
new build number → fast-tracked through internal/TestFlight smoke → staged production.

---

*See also: [`CONCEPT.md`](./CONCEPT.md) · [`QA_PLAN.md`](./QA_PLAN.md) ·
[`MONETIZATION.md`](./MONETIZATION.md) · [`ANALYTICS.md`](./ANALYTICS.md) ·
[`ARCHITECTURE.md`](./ARCHITECTURE.md) · [`ROADMAP.md`](./ROADMAP.md)*
