# NovaPlay — Design System (Sprint 6)

> Derived from `CONCEPT.md` (Locked v1.0) and `UI_GUIDELINES.md` (Sprint 3).
> This is the **implementation-oriented** source for tokens and components. It is
> **dark-first**: the dark cosmic theme is the default and primary theme; a light
> theme is not in scope for v1.0 (tokens are structured so one could be added later).
>
> All tokens map to Flutter via a `ThemeExtension` (`NovaTokens`) plus a tuned
> `ThemeData`. Numeric values are in logical pixels (dp/sp). Colors are sRGB hex.

---

## 1. Design Tokens

### 1.1 Color System

Dark-first. Names are semantic; hex values are concrete. `on*` = foreground color
to place *on* the named surface (contrast-checked).

#### Space / background gradients

| Token | Hex | Use |
|---|---|---|
| `space.900` | `#05060E` | Deepest void; app scaffold base / gameplay backdrop. |
| `space.800` | `#0A0C1A` | Primary background. |
| `space.700` | `#11142A` | Background gradient mid stop. |
| `space.600` | `#1A1E3C` | Background gradient top stop / elevated void. |
| `gradient.space` | `linear 180° [#1A1E3C → #0A0C1A → #05060E]` | Default screen background. |
| `gradient.nebula` | `radial [#3A2A6E @ 0% → transparent @ 70%]` | Soft accent glow behind hero elements. |

#### Surfaces & on-colors

| Token | Hex | Notes |
|---|---|---|
| `surface.base` | `#0F1226` | Cards, sheets baseline. |
| `surface.raised` | `#171B36` | Raised cards, dialogs. |
| `surface.overlay` | `#1E2342` | Top sheets, menus, popovers. |
| `surface.scrim` | `#05060E @ 64%` | Modal scrim behind dialogs. |
| `on.high` | `#F4F6FF` | Primary text (soft off-white, never pure #FFFFFF). |
| `on.medium` | `#AEB4D6` | Secondary text, labels. |
| `on.disabled` | `#5C6182` | Disabled text/icon. |
| `border.subtle` | `#FFFFFF @ 8%` | Hairline separators. |
| `border.strong` | `#FFFFFF @ 16%` | Interactive outlines (ghost buttons, ≥3:1). |

#### Star / Nova accents (the hero)

| Token | Hex | Use |
|---|---|---|
| `nova.500` | `#FFC857` | **Primary accent** — the spark / primary buttons / lit star core. |
| `nova.400` | `#FFD884` | Hover/active highlight. |
| `nova.600` | `#E0A53C` | Pressed/edge. |
| `nova.glow` | `#FFC857 @ 40%` | Bloom/glow color for lit stars & wins. |
| `star.dim` | `#5C6182` | Unlit / dim star fill. |
| `star.lit` | `#FFE6A8` | Lit star body (warm white-gold). |
| `stardust` | `#A98BFF` | Premium currency (violet), distinct from coins. |
| `coin` | `#FFC857` | Soft currency (shares nova gold; differentiated by icon). |

#### Sector accents (color-blind-safe: vary hue **and** lightness)

| Sector | Token | Hex | Character |
|---|---|---|---|
| Embers (1–20) | `sector.embers` | `#FF8A5C` | Warm orange. |
| Nebula (21–40) | `sector.nebula` | `#C77DFF` | Violet-magenta. |
| Void (41–60) | `sector.void` | `#4DA3FF` | Cool blue. |
| Pulsar (61–80) | `sector.pulsar` | `#3FD0C9` | Teal-cyan. |
| Singularity (81–100) | `sector.singularity` | `#F2F4FF` | Pale platinum-white. |

> Each sector is **also** keyed by its name + icon, never color alone (§Accessibility,
> `UI_GUIDELINES.md`). Lightness ranges spread (orange→violet→blue→teal→near-white)
> keep them separable under deuteranopia/protanopia.

#### Semantic colors

| Token | Hex | `on` |
|---|---|---|
| `success.base` | `#3FD98B` | `#04210F` |
| `warn.base` | `#FFB547` | `#2A1A00` |
| `error.base` | `#FF6B6B` | `#2A0808` |
| `info.base` | `#4DA3FF` | `#04162A` |

> Loss/fail UI deliberately does **not** use `error` red as a dominant color — it uses
> `on.medium` + `nova` to stay calm (`UI_GUIDELINES.md` §7).

### 1.2 Typography

**Pairing:** **Display = "Sora"** (geometric, slightly cosmic, great for headlines &
numbers) · **Text/UI = "Inter"** (highly legible at small sizes, broad Latin-Extended
coverage for localization). Both are open-source and bundle cleanly in Flutter.
Numerals: use Inter tabular figures for HUD counters (no jitter on count-up).

| Role | Font | Size (sp) | Weight | Line height | Use |
|---|---|---|---|---|---|
| `display` | Sora | 40 | 700 | 1.1 | Splash wordmark, big moments. |
| `h1` | Sora | 28 | 700 | 1.2 | Screen titles, Win headline. |
| `h2` | Sora | 22 | 600 | 1.25 | Section headers, dialog titles. |
| `h3` | Sora | 18 | 600 | 1.3 | Card titles. |
| `bodyLarge` | Inter | 16 | 400 | 1.45 | Primary body. |
| `bodyMedium` | Inter | 14 | 400 | 1.45 | Secondary body, list rows. |
| `label` | Inter | 14 | 600 | 1.2 | Buttons, tabs, chips. |
| `caption` | Inter | 12 | 400 | 1.3 | Helper text, timestamps. |
| `overline` | Inter | 11 | 600 (tracked +6%) | 1.2 | Section eyebrows ("AUDIO"). |
| `numeric` | Inter (tabular) | 16 | 700 | 1.0 | HUD counters, currency badges. |

Min body size 14sp; respect OS scaling to 130% (`UI_GUIDELINES.md` §6).

### 1.3 Spacing (4 / 8 pt)

| Token | dp | Token | dp |
|---|---|---|---|
| `space.0` | 0 | `space.4` | 16 |
| `space.0_5` | 2 | `space.5` | 20 |
| `space.1` | 4 | `space.6` | 24 |
| `space.2` | 8 | `space.8` | 32 |
| `space.3` | 12 | `space.10` | 40 |
| | | `space.12` | 48 |

Screen edge padding default `space.4` (16). Section gaps `space.6` (24).

### 1.4 Radius

| Token | dp | Use |
|---|---|---|
| `radius.xs` | 6 | Chips, small badges. |
| `radius.sm` | 10 | Buttons, inputs. |
| `radius.md` | 16 | Cards. |
| `radius.lg` | 24 | Sheets, dialogs, pack cards. |
| `radius.pill` | 999 | Pills (lives, currency badges), FAB-like CTAs. |
| `radius.full` | circle | Level nodes, avatar, icon buttons. |

### 1.5 Elevation / Shadow

Dark UIs favor **glow + surface-tint** over heavy drop shadows.

| Token | Spec | Use |
|---|---|---|
| `elev.0` | none (flat on background) | Base content. |
| `elev.1` | `surface.raised` + shadow `0 2 8 #000 @ 24%` | Cards. |
| `elev.2` | `surface.overlay` + shadow `0 8 24 #000 @ 32%` | Dialogs, sheets. |
| `elev.glow.nova` | `0 0 24 nova.glow` | Primary CTA & lit stars (luminous, not drop). |
| `elev.glow.sector` | `0 0 20 sector.* @ 35%` | Active/next level node. |

### 1.6 Opacity

| Token | Value | Use |
|---|---|---|
| `opacity.disabled` | 0.38 | Disabled controls. |
| `opacity.muted` | 0.64 | Secondary/inactive. |
| `opacity.scrim` | 0.64 | Modal scrim. |
| `opacity.hint` | 0.24 | Trajectory dots, faint hints. |
| `opacity.pressed` | 0.12 | Pressed overlay on surfaces. |

### 1.7 Z-index / Layering

| Layer | z | Contents |
|---|---|---|
| `z.background` | 0 | Space gradient, parallax starfield. |
| `z.board` | 10 | Gameplay field (Flame canvas). |
| `z.content` | 20 | Screen content, cards, nav. |
| `z.hud` | 30 | Persistent HUD / gameplay HUD. |
| `z.sheet` | 40 | Bottom sheets, menus. |
| `z.scrim` | 50 | Modal scrim. |
| `z.dialog` | 60 | Dialogs, Pause, result overlays. |
| `z.toast` | 70 | Snackbars / toasts. |
| `z.coach` | 80 | Onboarding coach marks. |
| `z.system` | 90 | Loading veil, ad surfaces. |

---

## 2. Iconography

- **Style:** outline-first, 2 dp stroke, rounded caps/joins, on a 24×24 grid;
  filled variants reserved for *active/selected* states (e.g., active nav tab).
- **Geometry:** geometric & calm to match Sora; avoid ultra-detailed glyphs that
  blur at small sizes.
- **Color:** icons inherit `on.medium` by default, `on.high` when active, accent
  (`nova`/`sector`) only for status-bearing icons (spark, currency).
- **Hit area:** glyph may be 24 dp but the tappable `IconButton` is ≥ 48×48 dp.
- **Semantic glyphs** (never color-only): padlock (locked), star outline/fill
  (rating), ◇ (rewarded ad), 🔥 streak, ❤ lives, 🪙 coin, ✦ stardust.
- **Asset format:** prefer vector (`flutter_svg`) or an icon font for crisp scaling
  & easy theming; no PNG-baked text.

---

## 3. Theming Approach (Flutter)

- **Single dark theme** as `ThemeData(brightness: dark)` carrying Material-mapped
  basics (`colorScheme`, `textTheme` from Sora/Inter via `google_fonts` or bundled).
- **Custom tokens via `ThemeExtension`** named `NovaTokens` — anything Material's
  `ColorScheme` can't express (sector accents, glows, gradients, spacing, radii,
  game-specific colors like `star.dim`/`star.lit`).

```dart
@immutable
class NovaTokens extends ThemeExtension<NovaTokens> {
  final Color novaPrimary, starDim, starLit, stardust, coin;
  final Map<Sector, Color> sectorAccent;
  final Gradient spaceBackground, nebulaGlow;
  final NovaSpacing spacing;     // 4/8pt scale
  final NovaRadii radii;
  final List<BoxShadow> novaGlow;
  // ... success/warn/error, opacities, etc.
  @override NovaTokens copyWith({...});
  @override NovaTokens lerp(ThemeExtension<NovaTokens>? other, double t) {...}
}
```

- **Access in widgets:** `final t = Theme.of(context).extension<NovaTokens>()!;`
  Provide a tiny `BuildContext` extension `context.nova` for ergonomics.
- **Mapping rule:** Material semantics (`primary`, `surface`, `error`, `onSurface`)
  carry the standard meanings so stock widgets look right out of the box; **all
  brand/game tokens live in `NovaTokens`**. Components read from `NovaTokens` first.
- **No hard-coded colors/sizes in widgets** — always go through the theme/extension.
  This keeps a future light theme or re-skin a single-file change.
- **Riverpod note:** theme is static; user prefs (reduced motion, haptics) live in a
  settings provider read by components, *not* baked into the theme.

---

## 4. Component Library

For each: **purpose · anatomy · states · Flutter structure.** Proposed widget names
are collected in §6.

### 4.1 Buttons

**Variants:** Primary, Secondary, Ghost, Icon.

- **Purpose:** drive the one primary action (Primary), supporting actions
  (Secondary), low-emphasis/cancel (Ghost), compact glyph actions (Icon).
- **Anatomy:** container (radius `sm`/`pill`) → optional leading icon → label
  (`label` type) → optional trailing. Primary carries `elev.glow.nova`.
- **Colors:** Primary = `nova.500` bg / `space.900` text. Secondary = `surface.overlay`
  bg / `on.high` text + `border.strong`. Ghost = transparent / `on.medium` text.
  Icon = transparent, `on.medium` glyph.
- **States:** default · hover (n/a touch) · pressed (`opacity.pressed` overlay,
  scale 0.97) · disabled (`opacity.disabled`) · loading (spinner replaces label,
  width locked) · armed (boosters: accent ring).
- **Sizing:** height 48 (standard), 56 (hero result CTA), min hit 48×48.
- **Flutter:** thin wrappers over `FilledButton`/`OutlinedButton`/`TextButton`/
  `IconButton` with styles sourced from `NovaTokens`; central `NovaButton` taking a
  `NovaButtonVariant` enum.

### 4.2 Cards

- **Purpose:** group related content (loadout, shop pack, profile stat, achievement).
- **Anatomy:** `surface.raised`, `radius.md`, padding `space.4`, optional header row,
  body, optional footer/CTA. `elev.1`.
- **States:** static · pressable (ripple + `opacity.pressed`) · selected
  (`border.strong` → accent border + faint sector glow) · disabled.
- **Flutter:** `NovaCard` = `Material`(`surface.raised`) + `InkWell` (when tappable)
  + `Padding`; selection handled by an `isSelected` flag toggling border decoration.

### 4.3 Dialogs / Modals

- **Purpose:** focused decisions and result moments (Pause, Win, Lose, Purchase
  confirm, sign-out confirm).
- **Anatomy:** `surface.scrim` backdrop → centered `surface.overlay` panel
  (`radius.lg`, `elev.2`) → title (`h2`) → body → action row (Primary + Ghost).
- **States:** entering (scale 0.96→1 + fade, 240 ms) · idle · exiting (fade, 180 ms)
  · loading (action shows spinner).
- **Flutter:** `showDialog` + `NovaDialog` scaffold; result overlays (Win/Lose) are
  full-bleed variants `NovaResultOverlay` layered at `z.dialog` over the frozen board.

### 4.4 Bottom Sheets

- **Purpose:** contextual choices that keep board/screen context (Lives refill,
  booster info, language picker).
- **Anatomy:** drag handle → `surface.overlay` rounded-top panel (`radius.lg` top
  corners) → content → action row. Reaches into the thumb zone.
- **States:** dragging (follows finger, snap points) · settled · dismissing (slide
  down + scrim fade) · expanded vs. half (if scrollable).
- **Flutter:** `showModalBottomSheet` + `NovaSheet`; `DraggableScrollableSheet` when
  content scrolls.

### 4.5 Toasts / Snackbars

- **Purpose:** transient, non-blocking confirmation ("Purchased", "Synced",
  "Restored"). Never for critical decisions.
- **Anatomy:** `surface.overlay` pill (`radius.pill`), leading status icon (success/
  info/error tint), `bodyMedium` text, optional single inline action.
- **States:** enter (slide up + fade, 220 ms) · visible (3–4 s) · exit (fade) ·
  with-action (persists until tapped/timeout).
- **Flutter:** `ScaffoldMessenger` + custom `NovaSnackBar` content at `z.toast`.

### 4.6 HUD Elements

#### Spark counter
- **Purpose:** show remaining/used sparks in gameplay — the only persistent play status.
- **Anatomy:** a row of pip glyphs ✦ (filled = remaining `nova.500`, hollow = used
  `star.dim`); compact "n/m" tabular fallback when count is high.
- **States:** full · decremented (pip dims with a tick) · last spark (gentle pulse)
  · zero (no glow). **Flutter:** `SparkCounter` = `Row` of `SparkPip` widgets.

#### Coin / Lives pill
- **Purpose:** show currency / energy on hub screens; tappable to Shop / refill.
- **Anatomy:** `radius.pill`, `surface.overlay`, leading icon (🪙/❤), `numeric` value;
  lives pill appends a `caption` countdown timer when not full.
- **States:** default · increasing (count-up + brief glow) · full (timer hidden) ·
  empty (subtle warn tint, taps to refill). **Flutter:** `CurrencyPill` / `LivesPill`.

#### Star meter
- **Purpose:** show level/sector star progress (e.g., 41/60) on map & profile.
- **Anatomy:** ⭐ icon + `numeric` "earned/total", optional thin progress bar.
- **States:** static · increment (star pops, bar fills). **Flutter:** `StarMeter`.

### 4.7 Currency Badges

- **Purpose:** top-HUD coins & stardust entry points.
- **Anatomy:** `radius.pill` mini-pill: currency glyph + abbreviated `numeric`
  (`1.2k`), optional trailing `+` affordance routing to Shop.
- **States:** default · count-up (with fly-in particle on reward) · pressed.
- **Flutter:** `CurrencyBadge` (variant: coin | stardust); shares format util with pills.

### 4.8 Level Node

- **Purpose:** a single level on the sector map.
- **Anatomy:** circular node (`radius.full`), center label (level # or padlock or ✦
  finale), star triad arc below, sector-accent ring.
- **States:**
  - **Locked:** dim fill `surface.base`, `on.disabled` padlock, no glow.
  - **Unlocked / next:** sector-accent ring + `elev.glow.sector` breathing pulse,
    bright number.
  - **Cleared:** lit fill, number in `on.high`, 0–3 filled/outline stars below.
  - **Finale (Supernova):** larger diameter, dual-ring, stronger glow.
  - **Pressed:** scale 0.95.
- **Flutter:** `LevelNode` taking a `LevelNodeState` enum + `stars` (0–3) + `sector`;
  star arc = `StarTriad` widget.

### 4.9 Progress Bars

- **Purpose:** XP, sector completion, loading progress, multi-hit star fill.
- **Anatomy:** track `border.subtle` rounded (`radius.pill`), fill `nova.500` (XP) or
  `sector.*`; optional inline label.
- **States:** determinate (animated fill, `easeOut`) · indeterminate (shimmer,
  loading) · complete (brief glow). **Flutter:** `NovaProgressBar` (linear),
  `NovaProgressRing` (sector ring on map nodes).

### 4.10 Toggles & Sliders (Settings)

- **Toggle:** purpose = boolean prefs (haptics, reduced motion). Anatomy = track +
  thumb pill; on = `nova.500` track. States: on/off/disabled, 120 ms thumb slide.
  **Flutter:** `NovaSwitch` wrapping `Switch` with themed colors.
- **Slider:** purpose = continuous prefs (music/SFX volume). Anatomy = track, active
  `nova.500` fill, thumb, value caption. States: idle/dragging/disabled.
  **Flutter:** `NovaSlider` wrapping `Slider`; tap target ≥ 48 dp tall.

### 4.11 Loading & Skeletons

- **Purpose:** cover preloads (splash, shop fetch, cloud sync) without spinners
  everywhere.
- **Anatomy:** **Splash veil** (shimmering starfield, no %); **inline skeletons**
  (`surface.raised` blocks with a low-opacity sweep) matching final layout shape.
- **States:** loading (sweep, ≤ 0.7 Hz) · resolved (cross-fade to content, 200 ms) ·
  error → Error state (§4.12). **Flutter:** `NovaSkeleton` (shimmer box),
  `NovaLoadingVeil`.

### 4.12 Empty / Error States

- **Purpose:** graceful zero-data / failure (no achievements yet, shop offline, sync
  failed).
- **Anatomy:** centered calm illustration glyph + `h3` line + `bodyMedium` subline +
  single Ghost/Secondary CTA ("Retry", "Browse boosters").
- **States:** empty (encouraging) · error (calm `info`/`warn`, never alarmist red wall)
  · retrying (CTA → loading). **Flutter:** `NovaStateView` (variant: empty | error)
  with `title`, `message`, `icon`, optional `action`.

---

## 5. Animation / Micro-interaction Specs (per component)

Durations/easings follow `UI_GUIDELINES.md` §5; all respect Reduced Motion.

| Component | Interaction | Spec |
|---|---|---|
| Button | press | scale 0.97 + `opacity.pressed` overlay, 90 ms `easeOut`. |
| Button (primary) | idle glow | static `elev.glow.nova`; **no** pulsing. |
| Toggle | switch | thumb slide 120 ms `easeOut`; track color cross-fade. |
| Slider | drag | thumb tracks 1:1; value caption updates live. |
| Card (pressable) | tap | ripple from touch + 60 ms lift to `elev.2`. |
| Dialog | open/close | scale 0.96→1 + fade in 240 ms; fade out 180 ms. |
| Bottom sheet | open/close | slide up 260 ms emphasized; slide down 200 ms. |
| Snackbar | show/hide | slide-up+fade 220 ms; auto-dismiss 3.5 s. |
| Spark pip | spent | dim + 1 px shrink, 100 ms; last pip 1.4 s breathe. |
| Currency badge | reward | fly-in particle to badge, then count-up 700 ms `easeOut` + glow. |
| Level node (next) | idle | glow breathe 1.4 s loop `easeInOut`, low amplitude. |
| Level node | unlock | ring draw-on 400 ms + single bloom. |
| Star (Win) | reveal | staggered pop `easeOutBack` 180 ms each, +120 ms apart, chime per star. |
| Progress bar | fill | width `easeOut` 600 ms; complete → 300 ms glow. |
| Skeleton | loading | shimmer sweep 1.2 s loop; resolve cross-fade 200 ms. |
| Win overlay | enter | board freeze → light bloom 800 ms (the one spectacle) → rewards. |
| Reduced Motion | all | replace slide/scale with cross-fade; bloom→simple fade; loops→static. |

---

## 6. Reusable Widget Catalog (to build in Sprint 6)

Proposed widget names, grouped. All read tokens from `NovaTokens`.

**Foundation / theming**
- `NovaTokens` (ThemeExtension) · `NovaSpacing` · `NovaRadii` · `context.nova` ext
- `NovaScaffold` (gradient background + safe areas) · `SpaceBackground` · `Starfield`

**Buttons & controls**
- `NovaButton` (variant: primary | secondary | ghost) · `NovaIconButton`
- `NovaSwitch` · `NovaSlider` · `NovaTabBar` · `NovaSegmented`

**Containers & overlays**
- `NovaCard` · `NovaDialog` · `NovaResultOverlay` (Win/Lose) · `NovaSheet`
- `NovaSnackBar` · `NovaScrim` · `PauseMenu`

**HUD & currency**
- `SparkCounter` / `SparkPip` · `CurrencyPill` · `CurrencyBadge` · `LivesPill`
- `StarMeter` · `BoosterTray` / `BoosterButton`

**Map & progression**
- `GalaxyMap` · `SectorNode` · `LevelNode` · `StarTriad` · `ConstellationPath`
- `NovaProgressBar` · `NovaProgressRing` · `XpBar`

**States & feedback**
- `NovaSkeleton` · `NovaLoadingVeil` · `NovaStateView` (empty | error)
- `CoachMark` · `RewardCountUp` · `ConfettiBloom` (reduced-motion aware)

**Domain screens (composed from the above)**
- `SplashScreen` · `OnboardingFlow` · `HomeMapScreen` · `LevelSelectScreen`
- `GameplayHud` · `WinOverlay` · `LoseOverlay` · `SettingsScreen` · `ProfileScreen`
- `ShopScreen` · `DailyRewardSheet` · `PreLevelLoadout`
