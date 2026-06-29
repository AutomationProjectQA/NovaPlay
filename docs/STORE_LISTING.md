# STORE_LISTING.md — App Store Optimization (ASO)

> Sprint 21 deliverable. The store positioning, keyword strategy, and the
> character-limit rules behind the metadata in [`store/metadata/`](../store/metadata).
> Edit the `.txt` files there; this doc is the *why*.

## 1. Positioning

**One-liner:** *Light the constellations* — a calm, one-handed physics puzzle in
deep space. **Category:** Games ▸ Puzzle. **Audience:** relaxation-seeking casual
puzzle players (the "zen puzzle" cohort that plays one-handed, often before bed).

**Differentiators to lead with:** calm/no-timer framing, the satisfying
slingshot-and-light loop, handcrafted (not procedurally spammed) levels, and
fairness (no forced ads / no pay-to-win).

## 2. Metadata & character limits

| Field | Google Play | App Store | Our value (en) |
|---|---|---|---|
| Title / Name | ≤ 30 | ≤ 30 | `NovaPlay – Star Puzzle` (24) |
| Subtitle | — | ≤ 30 | `Calm constellation puzzle` (25) |
| Short description | ≤ 80 | — | 74 chars |
| Keywords field | — (uses listing text) | ≤ 100 | 80 chars |
| Full description | ≤ 4000 | ≤ 4000 | see `full_description.txt` |
| Promotional text | — | ≤ 170 (no review) | localized |
| Release notes | yes | yes | localized |

All three locales (`en`, `es`, `ar`) are filled and within limits (verified at
authoring time). Arabic uses the `ar` folder for Play and `ar-SA` for App Store.

## 3. Keyword strategy

- **App Store keywords field** (the high-signal lever): comma-separated, **no
  spaces, no plurals, no repetition of words already in the name/subtitle** (that
  wastes characters). Current set: `puzzle,star,constellation,space,relax,brain,
  casual,physics,galaxy,zen,logic,nova`.
- **Google Play** has no keyword field — it indexes the **title + short + full
  description**, so the primary terms (puzzle, star, constellation, space, relax)
  are woven naturally into the copy, especially the first 2 lines (highest weight).
- **Avoid** competitor brand names (rejection risk) and keyword stuffing (reads
  spammy, hurts conversion). Density target: each primary term appears 1–2× in the
  full description, no more.
- **Iterate post-launch:** treat keywords as a living asset — review the ASO
  dashboard monthly, swap low-impression terms (RELEASE_PLAN §7 / post-launch).

## 4. Creative assets (tracked in `store/screenshots/`)

- **Icon:** the Nova spark mark on the deep-space gradient (see `flutter_launcher_icons`).
- **Feature graphic (Play, 1024×500):** wordmark + a lit constellation.
- **Screenshots:** 5 scenes × 3 locales, auto-captured — sizes and recipe in
  [`store/screenshots/README.md`](../store/screenshots/README.md). The first two
  screenshots do the heavy lifting; lead with gameplay + the win spectacle, not menus.
- **Preview video (optional):** 15–30s of the slingshot-and-light loop.

## 5. Conversion notes (player psychology)

- The first screenshot is seen by ~everyone; the full description by <10%. Front-load
  value in the **first screenshot + first description line**.
- "No timers, no pressure" is the emotional hook for this cohort — keep it in the
  short description, where it's always visible.
- Localize screenshots' captions, not just the listing — Arabic RTL captions
  signal genuine localization and lift MENA conversion.

## 6. Workflow

The metadata is the source of truth in `store/metadata/`; the listing is published
from it via fastlane `supply` (Play) / `deliver` (App Store) — see
[RELEASE_PLAN.md](RELEASE_PLAN.md) §6. Never hand-edit the consoles.
