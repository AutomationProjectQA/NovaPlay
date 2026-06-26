# NovaPlay — Monetization & Economy Design

> Derived from `CONCEPT.md` (canonical, Locked v1.0). If anything here conflicts with the
> Concept Bible, the Concept Bible wins. Covers **Sprint 13 (Economy)** and **Sprint 16 (Ads)**.
> All revenue/eCPM/KPI figures are clearly labeled **ESTIMATES** or **TARGETS** until validated
> by live telemetry.

---

## 1. Monetization philosophy

NovaPlay is **free-to-play, value-positive, and strictly no pay-to-win**. The four design
pillars from the Concept Bible (readable physics, "one more try", elegant escalation, calm
spectacle) extend directly into how we make money:

- **Every level is solvable for free.** No level, including Supernova finales, requires a
  purchase, a booster, or watching an ad. Boosters and IAP buy **time, convenience, and flair** —
  never a solution the free player cannot reach.
- **Ads are opt-in first.** Rewarded video (the player chooses to watch for a clear benefit) is
  our primary, least-intrusive driver. Interstitials are tightly capped and never interrupt a
  shot in flight.
- **The offer always answers "what's in it for me right now?"** We surface rewarded ads and
  boosters at moments of genuine player need ("so close", out of lives), not as nags.
- **No dark patterns.** No fake timers, no disguised-close buttons, no confusing currency math,
  no bait-and-switch pricing. Coin/stardust conversions are shown transparently.
- **Respect the calm tone.** Monetization UI matches the premium "lofi space" aesthetic; it is
  quiet, never carnival-loud.

**Guardrail:** if a proposed mechanic would let a paying player clear a level a free player
realistically cannot, it is rejected. Difficulty is tuned against the **free** experience.

---

## 2. Revenue streams overview

| Stream | Mechanism | Intrusiveness | Role | Expected revenue mix (ESTIMATE) |
|---|---|---|---|---|
| **Rewarded ads** | Opt-in video for a concrete benefit | Low (player-chosen) | Primary driver, broad reach | **45–55%** |
| **Interstitial ads** | Capped full-screen between levels | Medium | Volume monetization of non-payers | **20–30%** |
| **IAP — Remove Ads** | One-time unlock (+perks) | None | Anchor purchase, lifts ARPPU | **10–15%** |
| **IAP — consumables** | Coin/stardust/booster packs, starter pack | None | Depth monetization of engaged players | **8–12%** |
| **IAP — cosmetics** | Spark skins, backgrounds (post-MVP) | None | Whale/expression spend | **3–6%** |

> **Mix is an estimate** for a mass-market casual puzzle title. Ads dominate because the
> audience (18–45 casual, ad-friendly) converts to IAP at low single-digit rates. Banner ads
> are intentionally excluded (see §6.3).

**Headline blend target (TARGET, post-soft-launch):** ad ARPDAU ≈ 60–70% of total ARPDAU,
IAP ARPDAU ≈ 30–40%.

---

## 3. Economy design

Four currencies/resources, exactly as locked in `CONCEPT.md §7`: **Coins** (soft),
**Stardust** (hard/premium), **Lives/Energy** (session gate), **XP/Player Level** (progression).

### 3.1 Coins (soft currency)

Coins are the everyday currency — earned constantly, spent on boosters and life refills.

**Coin sources** (ESTIMATE — tunable via Remote Config):

| Source | Amount (coins) | Notes |
|---|---|---|
| Clear a level (first time) | **20** | Base completion reward |
| Clear a level (replay) | **5** | Reduced to discourage farming |
| Per star earned | **+10 / star** | 1★=10, 2★=20, 3★=30 on top of base |
| Collect a stardust mote on board | **+5 each** | Optional collectibles (efficiency path) |
| Daily reward (login) | **15–100** | Scales with streak day (see §8 retention) |
| Daily Challenge clear | **50** | Once per day |
| Mission (daily) | **25–75** | Per mission |
| Mission (weekly) | **150–300** | Per mission |
| Lucky Wheel / Chest | **10–250** | Variable (post-MVP) |
| Rewarded ad — "double coins" | **= level reward** | Doubles the just-earned coins |
| Rewarded ad — daily coin gift | **30** | Once/day, opt-in |
| Sector finale (Supernova) clear | **100** | Milestone bonus |

**Coin sinks** (ESTIMATE — tunable):

| Sink | Cost (coins) | Notes |
|---|---|---|
| Guided Line (booster) | **80** | Common booster |
| Slow-Mo (booster) | **120** | |
| Extra Spark (booster) | **150** | High-value, used at "so close" moments |
| Bomb Spark (booster) | **180** | |
| Rewind / Undo (booster) | **100** | |
| Single life refill | **200** | Or free via rewarded ad / regen |
| Full lives refill (to cap) | **600** | Discounted vs. 5×200 |
| Pre-level loadout (1 booster) | booster cost | Equip before launch |
| Cosmetic spark skin (soft-tier) | **2,500–5,000** | Entry cosmetics buyable with coins |

> **Target sink/source ratio:** an engaged free player should run a **mild coin deficit** after
> ~30–45 min/day of normal play, creating a reason to watch rewarded ads or buy a coin pack,
> **without** ever being blocked from a level. Tuned to telemetry (§9).

### 3.2 Stardust (hard / premium currency)

Stardust is **scarce and aspirational**. Primarily acquired via IAP; earned sparingly so it
feels premium. Never required to clear a level.

**Stardust sources** (ESTIMATE):

| Source | Amount | Notes |
|---|---|---|
| Achievement unlocked | **5–25** | One-time per achievement |
| Sector fully 3-starred | **50** | Mastery reward |
| Seasonal event milestone | **10–40** | Post-MVP |
| IAP packs | **see §7** | Primary source |
| Special daily streak day (e.g. day 7) | **20** | Streak capstone |

**Stardust sinks** (ESTIMATE):

| Sink | Cost (stardust) | Notes |
|---|---|---|
| Premium booster bundle (5×) | **40** | Pre-loaded premium boosters |
| Level skip token | **15** | Skips a level you've failed ≥3× (keeps 1★); never forced |
| Exclusive cosmetic skin | **150–400** | Premium spark skins / backgrounds |
| Exclusive background | **120–300** | |
| Continue at Supernova (extra spark on boss) | **10** | Convenience, free path still exists |
| Convert stardust → coins | **1 stardust = 100 coins** | One-way; transparent rate shown in UI |

> **Conversion rule:** stardust → coins is allowed (transparent, one-way). Coins → stardust is
> **not** allowed (protects the premium tier). Rate is a Remote Config knob.

### 3.3 Lives / Energy (session gate)

Per `CONCEPT.md §7`: **1 life regenerates per 20 minutes, cap 5.** A life is consumed on a
**failed** attempt (out of sparks with stars still dim). **Winning never costs a life.**

| Parameter | Value | Tunable? |
|---|---|---|
| Regen rate | **1 life / 20 min** | Remote Config |
| Cap (free) | **5** | Remote Config |
| Cap (with Remove Ads / starter perk) | **8** (ESTIMATE) | Remote Config |
| Life consumed on | **Level fail only** | Fixed by design |
| Time to full from empty | **~100 min** | Derived (5 × 20 min) |
| Tutorial / first sector grace | **Levels 1–10 cost no life on fail** | Onboarding protection |

**Life refill options:**

| Method | Cost | Cap interaction |
|---|---|---|
| Wait (regen) | Free | Stops at cap |
| Rewarded ad — "free life" | Watch 1 video | +1 life, can exceed regen but not above cap+overflow window |
| Coins | **200 / life**, **600 / full** | Can overfill to cap |
| Stardust | **5 / full refill** | Convenience |
| IAP — Remove Ads | Raises cap + faster regen perk | Permanent |

> Lives create return visits and gentle session pacing **without punishing skill** — a good
> player who wins rarely loses lives. The pinch point is intentional friction for strugglers,
> always relievable via a free rewarded ad.

### 3.4 XP / Player Level (progression, non-monetized)

XP is **purely progression** — it is **not** a sink for any currency and **cannot** be bought.
It gates cosmetic unlocks and profile flair, reinforcing long-term goals.

| XP source | Amount (ESTIMATE) |
|---|---|
| Clear a level | **+10** |
| Per star | **+5 / star** |
| Daily Challenge | **+25** |
| Mission complete | **+15–50** |
| Sector finale | **+50** |

Player level thresholds use a gentle curve (e.g. `XP_to_next = 100 + level × 50`). Level-ups
grant **cosmetic unlocks, a coin bonus, and profile flair** — never gameplay power.

### 3.5 Economy balance — sources vs. sinks (summary)

| Resource | Primary sources | Primary sinks | Designed pressure |
|---|---|---|---|
| **Coins** | Level clears, stars, dailies, rewarded ads | Boosters, life refills, soft cosmetics | Mild deficit → rewarded ads / coin packs |
| **Stardust** | Achievements, mastery, IAP | Premium boosters, exclusive cosmetics, skip | Scarce → IAP for cosmetics/convenience |
| **Lives** | Time regen, ads, IAP | Failed attempts | Friction only when struggling; ad-relievable |
| **XP** | All play | None (non-spendable) | Pure long-term progression |

**Balancing intent:** the free player always has a **viable, un-gated path**; spending and
ad-watching **accelerate** it. We monitor a per-cohort **coin balance over time** chart (§9) and
tune sources/sinks so the median engaged player hovers near zero net coins (engaged but not
starved).

---

## 4. Boosters

Five boosters from `CONCEPT.md §7`. Offered in two contexts: **pre-level loadout** (deliberate)
and **in-level "stuck?" offer** (reactive, at moments of need).

| Booster | Effect | Coin price | Stardust price | When offered |
|---|---|---|---|---|
| **Guided Line** | Extended aim/trajectory preview | 80 | 2 | Pre-level; offered after 1st fail |
| **Slow-Mo** | Slows the spark mid-flight | 120 | 3 | Pre-level; mid-flight tap |
| **Extra Spark** | One more shot this attempt | 150 | 4 | **In-level**, on "out of sparks" with stars left |
| **Bomb Spark** | Clears nearby asteroids on impact | 180 | 4 | Pre-level loadout |
| **Rewind** | Undo last shot | 100 | 3 | In-level, after a bad shot |

**Booster bundles** (better value to encourage stocking up):

| Bundle | Contents | Price | Implied value | Saving (ESTIMATE) |
|---|---|---|---|---|
| Starter Booster Pack | 3× Extra Spark, 3× Rewind | **350 coins** | 750 coins | ~53% |
| Premium Booster Pack | 5× mixed (1 of each + Extra Spark) | **40 stardust** | ~16 stardust à la carte | bundle premium |
| Mega Booster Pack | 10× mixed | **IAP $4.99** | — | see §7 |

**Free booster path:** a **rewarded ad grants one free booster per day** (Concept §9), and the
in-level "stuck?" Extra Spark can be claimed via **rewarded ad instead of coins** — preserving
the free-solvable guarantee.

---

## 5. Lives / energy — monetization detail

(Mechanics in §3.3.) Monetization surfaces:

- **Out-of-lives modal** offers, in order of prominence: **① watch a rewarded ad (free +1 life)**,
  ② refill with coins (200/life, 600/full), ③ refill with stardust (5/full), ④ "Remove Ads &
  more lives" IAP cross-sell. Free option is always the most prominent (no dark patterns).
- **Regen timer** is always visible and accurate (no fake urgency).
- Remove Ads raises the cap (5 → 8, ESTIMATE) and improves regen as a **value-add perk**, not a
  required purchase.

---

## 6. Ad strategy

Ads via **AdMob** (`google_mobile_ads`). Mediation deferred per Concept (§11) but planned.

### 6.1 Rewarded ads (primary)

All rewarded ads are **opt-in**, clearly labeled with the reward, and never auto-play.

| Placement | Trigger | Reward | Cap (ESTIMATE) |
|---|---|---|---|
| **Extra Spark** | Level fail (out of sparks, stars remain) → "Watch to get 1 more spark" | +1 spark, continue attempt | ≤ 1 per failed attempt; ≤ 5/session |
| **Double Coins** | Level complete summary | Doubles coins earned this level | 1 per level clear |
| **Free Life refill** | Out-of-lives modal | +1 life | ≤ 3/day per player |
| **Free daily booster** | Home / pre-level | 1 random booster | 1/day |
| **Daily coin gift** | Home screen tile | +30 coins | 1/day |
| **Lucky Wheel extra spin** | Lucky Wheel (post-MVP) | 1 extra spin | 1/day |

> **Design rule:** the Extra-Spark rewarded ad is the key "one more try" lever — it must feel
> generous, not coercive. The same continue is also purchasable with coins so non-watchers aren't
> blocked.

### 6.2 Interstitial ads (capped)

Per `CONCEPT.md §9`: between levels, frequency-capped, **never mid-level**, **never in first
sessions**.

| Rule | Value (ESTIMATE — Remote Config) |
|---|---|
| Placement | Between levels, on the **level-complete → next** transition only |
| Frequency cap | **No more than 1 per ~3 levels** |
| Cooldown | **≥ 120 s** between interstitials |
| First-N grace | **No interstitials in the first 3 sessions** and **not before level 6** |
| Never shown | Mid-level, during a shot, on app cold start, immediately after a rewarded ad, after a purchase, on level **fail** |
| Suppressed if | Player owns **Remove Ads** |
| Daily cap | **≤ 8 interstitials/day** (ESTIMATE) |

> Showing an interstitial after a **fail** would punish the "one more try" loop, so it is
> explicitly forbidden. Interstitials follow **wins**, where mood is positive.

### 6.3 Banner ads — decision: **NONE in v1.0**

Banners are **excluded**. Rationale: they clash with the premium, minimal "calm spectacle"
aesthetic, deliver low eCPM, risk mis-taps on a one-handed portrait UI, and consume screen real
estate the puzzle board needs. We revisit only if soft-launch ad ARPDAU underperforms and a
**non-gameplay** surface (e.g. a static shop footer) tests cleanly. Default: no banners.

### 6.4 eCPM assumptions (ESTIMATES)

> Rough planning figures, blended global, pre-mediation. **Estimates only** — to be replaced by
> live mediation data.

| Format | eCPM (ESTIMATE) | Notes |
|---|---|---|
| Rewarded video | **$10–16** | Highest; opt-in, completion-gated |
| Interstitial | **$6–10** | Capped volume |
| Banner | (excluded) | n/a in v1.0 |

Tier-1 geos (US/UK/CA/AU) run materially higher; emerging markets lower. Model assumes a global
blend weighted toward the casual-puzzle audience.

### 6.5 Ad mediation note

Launch on **AdMob network direct**; **enable AdMob mediation post-soft-launch** (Concept §11)
with a waterfall/bidding mix (e.g. Meta Audience Network, Unity Ads, AppLovin, ironSource,
Liftoff) to lift eCPM via competition. All ad logic abstracted behind an `AdService` interface so
mediation is a config change, not a code rewrite.

---

## 7. IAP catalog

Via `in_app_purchase`. Prices in USD (store will localize). All products are **convenience or
cosmetic** — none are required to clear a level.

| Product ID | Type | Price (USD, ESTIMATE) | Contents |
|---|---|---|---|
| `novaplay.removeads` | Non-consumable | **$3.99** | Removes all interstitials; +200 coins; +3 life cap; faster regen perk |
| `novaplay.coins.small` | Consumable | **$0.99** | 1,000 coins |
| `novaplay.coins.medium` | Consumable | **$4.99** | 6,000 coins (+20% bonus) |
| `novaplay.coins.large` | Consumable | **$9.99** | 14,000 coins (+40% bonus) |
| `novaplay.coins.mega` | Consumable | **$19.99** | 32,000 coins (+60% bonus) — best value |
| `novaplay.stardust.small` | Consumable | **$2.99** | 50 stardust |
| `novaplay.stardust.medium` | Consumable | **$7.99** | 150 stardust (+15% bonus) |
| `novaplay.stardust.large` | Consumable | **$19.99** | 420 stardust (+30% bonus) |
| `novaplay.boosters.mega` | Consumable | **$4.99** | 10× mixed boosters |
| `novaplay.starterpack` | Non-consumable (one-time) | **$2.99** | Remove Ads (lite) + 2,000 coins + 30 stardust + 6 boosters — **first-time-buyer only, time-limited offer** |
| `novaplay.bundle.value` | Consumable | **$9.99** | 6,000 coins + 80 stardust + 8 boosters |
| `novaplay.skin.nebula` | Non-consumable (post-MVP) | **$1.99** | Cosmetic spark skin |
| `novaplay.skin.aurora` | Non-consumable (post-MVP) | **$2.99** | Cosmetic spark skin + matching trail |
| `novaplay.bg.deepfield` | Non-consumable (post-MVP) | **$1.99** | Cosmetic background |

**Notes & best practices:**

- **Starter Pack** is the highest-converting offer — shown once, early, to non-payers, clearly
  flagged as a one-time deal (a *real* limited offer, not a fake timer).
- **Remove Ads** is the anchor; coin/stardust packs use **escalating bonus %** to nudge larger
  tiers (transparent, shown as "+X% bonus").
- **Cosmetics** (skins/backgrounds) are post-MVP per Concept §12; entry-tier skins are also
  buyable with **coins** (§3.1) so non-payers can express themselves.
- All consumable grants and entitlements are **validated server-side** (Cloud Functions) and
  restorable for non-consumables.

---

## 8. A/B testing & Remote Config tuning hooks

Everything monetization-sensitive is **server-tunable via Firebase Remote Config** and
A/B-testable via Firebase A/B Testing, so we tune without app releases.

| Knob (Remote Config key, ESTIMATE naming) | Controls | Default |
|---|---|---|
| `ad_interstitial_level_interval` | Levels between interstitials | 3 |
| `ad_interstitial_cooldown_s` | Min seconds between interstitials | 120 |
| `ad_interstitial_grace_sessions` | First-N sessions with no interstitials | 3 |
| `ad_interstitial_grace_level` | First level eligible for interstitial | 6 |
| `ad_rewarded_caps` | Per-placement daily/session caps | see §6.1 |
| `econ_coins_per_level` / `econ_coins_per_star` | Coin rewards | 20 / 10 |
| `econ_booster_prices` | Booster coin/stardust costs | §4 |
| `econ_life_refill_cost` | Coins per life / full | 200 / 600 |
| `econ_lives_cap` / `econ_lives_regen_min` | Life cap & regen | 5 / 20 |
| `econ_stardust_to_coins_rate` | Conversion rate | 100 |
| `iap_prices` / `iap_pack_contents` | Storefront tiers & contents | §7 |
| `iap_starterpack_enabled` / `_window` | Starter offer & timing | on / sessions 2–10 |
| `difficulty_sparks_per_level` | Sparks granted per level (difficulty) | per-level |
| `offer_stuck_threshold_fails` | Fails before "stuck?" booster offer | 2 |

**A/B experiment backlog (examples):**

1. Interstitial interval 3 vs. 4 levels → ad ARPDAU vs. D7 retention trade-off.
2. Starter Pack price $1.99 vs. $2.99 vs. $3.99 → conversion × revenue.
3. Double-coins rewarded prompt copy/placement → opt-in rate.
4. Coin reward +20% globally → session length & sink behavior.
5. Lives cap 5 vs. 6 → retention vs. ad/IAP relief demand.

Each experiment is gated on a **guardrail metric** (D1/D7 retention, crash-free, session length)
so monetization gains never silently erode retention.

---

## 9. Pricing & reward balancing methodology (telemetry-driven)

We **do not guess and ship**; we instrument, observe, and tune. Pipeline:

1. **Instrument** every earn/spend with `currency_earned` / `currency_spent` events (see
   `ANALYTICS.md`), tagged with source/sink, balance-after, and `ab_cohort`.
2. **Model** the median engaged player's **coin balance over time** and **stardust accrual**, and
   the **lives-empty frequency** per sector. Watch for starvation (blocking) or runaway surplus
   (no reason to spend).
3. **Tune** sources/sinks via Remote Config to keep the median engaged free player near a **mild
   coin deficit** and rarely (but sometimes) lives-blocked — relievable for free via rewarded ads.
4. **A/B test** any change that affects money or difficulty before global rollout (§8).
5. **Guardrail**: roll back if D1/D7 retention, session length, or crash-free regress beyond
   thresholds, even if ARPDAU rises.
6. **Sink health checks:** each booster's usage rate and each placement's opt-in rate are reviewed
   weekly; unused boosters get re-priced or re-positioned.

**Difficulty ↔ economy link:** sparks-per-level (`difficulty_sparks_per_level`) is the master
difficulty knob and the main driver of Extra-Spark booster/ad demand. We tune difficulty against
the **free** player's clear rate (target curve in `LEVEL_DESIGN.md`), then let monetization
follow — never the reverse.

---

## 10. Monetization KPIs & targets

> All values are **TARGETS / ESTIMATES** for a mass-market casual puzzle title, to be validated
> in soft launch. Retention/engagement targets mirror `CONCEPT.md §13`.

| KPI | Definition | Target (ESTIMATE) |
|---|---|---|
| **ARPDAU** | Total revenue ÷ DAU | **$0.06–0.12** |
| **Ad ARPDAU** | Ad revenue ÷ DAU | **$0.04–0.08** |
| **IAP ARPDAU** | IAP revenue ÷ DAU | **$0.02–0.04** |
| **ARPPU** | IAP revenue ÷ paying users | **$8–15** |
| **IAP conversion %** | Payers ÷ active users (lifetime) | **1.5–3%** |
| **Rewarded opt-in rate** | Rewarded views ÷ rewarded offers shown | **≥ 30–45%** |
| **Rewarded views / DAU** | Avg rewarded completions per DAU/day | **2–4** |
| **Interstitial impressions / DAU** | Avg interstitials per DAU/day | **3–6** |
| **Remove Ads attach rate** | Remove-Ads buyers ÷ payers | **20–35%** |
| **Starter Pack conversion** | Buyers ÷ players shown the offer | **3–6%** |
| **eCPM (rewarded)** | Per §6.4 | **$10–16** |

Reported alongside **retention guardrails** (D1 ≥ 40%, D7 ≥ 18%, D30 ≥ 7% from Concept §13) so
revenue is always read in the context of player health.

---

## 11. Compliance

- **Ad consent (UMP / GDPR / CCPA):** integrate **Google UMP (User Messaging Platform)** consent
  flow before serving personalized ads in regulated regions; honor non-personalized-ads (NPA)
  fallback when consent is declined. Consent state gates ad personalization, not access to the
  free game.
- **Age-appropriate ads:** request **G-rated / max-ad-content-rating** ad content suitable for the
  broad 18–45 (and incidental younger) audience; tag the app's content rating correctly; comply
  with **Google Play Families** / Apple kids guidelines if the store age band requires it.
- **COPPA / children's data:** if the app could be used by children, set
  `tagForChildDirectedTreatment` / `tagForUnderAgeOfConsent` appropriately and disable
  personalized ads + restricted analytics for those users (see `ANALYTICS.md §privacy`).
- **Store policies:** comply with **Google Play** and **Apple App Store** policies on IAP
  (must use official billing), ad disclosure, loot/randomized rewards (disclose odds for
  Lucky Wheel/Chests), and metadata accuracy. Disclose "contains ads" and "in-app purchases".
- **Transparent pricing & no dark patterns:** real prices shown, real (not fake) limited offers,
  no disguised close buttons, no forced ads to progress, no confusing currency conversions, clear
  "Restore Purchases", easy access to settings. Rewarded ads are always **opt-in**.
- **Tax & receipts:** rely on store billing for tax handling; server-side receipt validation for
  all entitlements.

---

*End of MONETIZATION.md — sources for figures: derived from `CONCEPT.md`; all revenue, eCPM, and
KPI numbers labeled ESTIMATE/TARGET pending live telemetry.*
