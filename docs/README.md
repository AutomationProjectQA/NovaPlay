# NovaPlay — Documentation Index

**NovaPlay** is a calm-but-clever **cosmic physics puzzle** for mobile (Flutter + Flame,
Android & iOS): you launch a spark of starlight across a constellation and bounce, curve,
and ricochet it to **light every dim star** before your sparks run out. It's offline-first,
free-to-play (rewarded + frequency-capped interstitial ads, fair non-pay-to-win IAP), and
built around four pillars — readable physics, "one more try," elegant escalation, and calm
spectacle. The v1.0 MVP ships sectors 1–3 (≥ 60 of 100 handcrafted levels). _Tagline:_
**"Light the constellations."**

> [`CONCEPT.md`](./CONCEPT.md) is the **single source of truth**. If anything here conflicts
> with it, CONCEPT wins.

## Documents

| Doc | What it is | Sprint(s) |
|---|---|---|
| [`CONCEPT.md`](./CONCEPT.md) | Canonical concept bible — locked decisions on mechanic, scope, platforms, metrics | 0 |
| [`VISION.md`](./VISION.md) | Product vision, personas, and full risk register | 0 |
| [`COMPETITOR_ANALYSIS.md`](./COMPETITOR_ANALYSIS.md) | Market & competitor landscape, differentiation | 0 |
| [`ROADMAP.md`](./ROADMAP.md) | Sprint-by-sprint plan and v2 roadmap pointer | 0 |
| [`PRD.md`](./PRD.md) | Product requirements & exact acceptance criteria | 1 |
| [`GAME_DESIGN.md`](./GAME_DESIGN.md) | Core loop, mechanics, boosters, economy, progression design | 2 |
| [`UI_GUIDELINES.md`](./UI_GUIDELINES.md) | IA, screen flows, wireframes, UX & accessibility guidelines | 3 |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | App architecture, stack, min SDKs, data & state | 4 |
| [`NAVIGATION.md`](./NAVIGATION.md) | Routing model, route table, transitions, guards, analytics observer | 7 |
| [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md) | Visual tokens, typography, color, components | 3 / 6 |
| [`LEVEL_DESIGN.md`](./LEVEL_DESIGN.md) | Sectors, difficulty curve, level authoring & tooling | 10 |
| [`MONETIZATION.md`](./MONETIZATION.md) | Economy, ads, IAP, currencies, pricing, targets | 13 / 16 |
| [`ANALYTICS.md`](./ANALYTICS.md) | Event taxonomy, funnels, KPIs, dashboards | 17 |
| [`PERFORMANCE.md`](./PERFORMANCE.md) | Perf budget, render/startup/battery/asset optimizations, profiling | 18 |
| [`QA_PLAN.md`](./QA_PLAN.md) | Test strategy, cases, device matrix, beta plan | 19–20 |
| [`QA_REPORT.md`](./QA_REPORT.md) | QA pass results: coverage, a11y audit, edge-case matrix, known issues | 19 |
| [`LOCALIZATION.md`](./LOCALIZATION.md) | i18n setup, locales (en/es/ar), RTL, adding strings/languages | 20 |
| [`STORE_LISTING.md`](./STORE_LISTING.md) | ASO: positioning, keywords, metadata limits, creative spec | 21 |
| [`PRIVACY.md`](./PRIVACY.md) | Data collection → Play Data Safety, App Store labels, privacy manifest | 21 |
| [`RELEASE_PLAN.md`](./RELEASE_PLAN.md) | Store assets, release pipeline, launch & rollback | 21–22 |
| [`LIVEOPS.md`](./LIVEOPS.md) | Post-launch: health monitoring, A/B experiments, kill switch, content cadence | 23 |
| [`WEB_DEMO.md`](./WEB_DEMO.md) | Publish a public playable web build (GitHub Pages / Firebase / itch.io) | post-plan |
| [`legal/`](./legal) | Hostable Privacy Policy & Terms of Service | 22 |

## How to use these docs

- **Start with [`CONCEPT.md`](./CONCEPT.md)** — it's canonical. Every other doc derives from it.
- **Then [`VISION.md`](./VISION.md) and [`ROADMAP.md`](./ROADMAP.md)** for the "why" and the plan.
- **Building a feature?** Go [`PRD.md`](./PRD.md) → [`GAME_DESIGN.md`](./GAME_DESIGN.md) /
  [`LEVEL_DESIGN.md`](./LEVEL_DESIGN.md) → [`UI_GUIDELINES.md`](./UI_GUIDELINES.md) /
  [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md) → [`ARCHITECTURE.md`](./ARCHITECTURE.md).
- **Shipping?** [`QA_PLAN.md`](./QA_PLAN.md) for quality bar & beta, then
  [`RELEASE_PLAN.md`](./RELEASE_PLAN.md) for store launch.
- **Found a conflict?** CONCEPT wins — file an update against it, then reconcile the rest.
- Docs are versioned with the repo; propose changes via PR and keep them consistent with CONCEPT.
