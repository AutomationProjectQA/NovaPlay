# NovaPlay — Analytics & Telemetry

> Derived from `CONCEPT.md` (canonical, Locked v1.0) and `MONETIZATION.md`. Covers
> **Sprint 17 (Analytics)**. Target values mirror `CONCEPT.md §13`; estimates are labeled.

---

## 1. Analytics goals & guiding questions

Analytics exists to answer concrete product questions and to feed the telemetry-driven economy
tuning loop (`MONETIZATION.md §9`). We instrument with intent, not "log everything."

**Guiding questions:**

- **Acquisition → activation:** Do new players finish the tutorial and clear level 1? Where in
  onboarding do we lose them?
- **Retention:** Do players come back D1/D7/D30? Which sectors/levels cause churn?
- **Engagement:** How long are sessions, how many per day, how deep into the 100 levels?
- **Difficulty:** Which levels have low clear rates or high restart/fail counts? Is the curve
  smooth (Concept §6)?
- **Economy health:** Are players accumulating or starving on coins/stardust/lives? (Feeds
  `MONETIZATION.md §9`.)
- **Monetization:** Rewarded opt-in rate? Interstitial impact on retention? IAP funnel drop-off?
- **Stability:** Are we crash-free ≥ 99.5% and hitting 60 FPS on mid-tier devices (Concept §13)?

Every event below traces back to at least one of these questions; if it doesn't, we don't log it.

---

## 2. Tools

| Tool | Purpose |
|---|---|
| **Firebase Analytics (GA4)** | Core event collection, funnels, audiences, user properties |
| **Crashlytics** | Crash & non-fatal error reporting, crash-free rate, custom keys |
| **Firebase Performance Monitoring** | App start time, frame rendering (slow/frozen frames), network traces |
| **BigQuery export** | GA4 → BigQuery linked export for raw-event SQL, retention cohorts, economy modeling, LTV — the analytical backbone for `MONETIZATION.md §9` |
| **Remote Config + A/B Testing** | Experiment assignment (`ab_cohort`) tied to analytics for read-out |
| **Looker Studio / dashboards** | Visualization layer over GA4 + BigQuery (see §9) |

> BigQuery export is **required** for cohorted retention and economy balance modeling that GA4's
> UI cannot express. Enable the daily (and intraday) export at launch.

---

## 3. Event taxonomy

### 3.1 Naming conventions

- **snake_case**, lowercase, verb_noun or noun_verb (`level_start`, `ad_shown`).
- **Past/neutral tense** for completions (`level_complete`, `iap_success`).
- Parameter names also **snake_case**; reuse shared params across events for consistency.
- Respect GA4 limits: ≤ 40 chars event names, ≤ 25 params/event, ≤ 100 chars param values.
- **Shared parameters** (attached wherever relevant): `level_id`, `sector_id`, `session_id`,
  `player_level`, `ab_cohort`, `is_payer`, `ad_remove`, `app_version`, `platform`.
- Avoid reserved GA4 prefixes (`firebase_`, `google_`, `ga_`) and reserved event names.

### 3.2 Comprehensive event catalog

| Event | Trigger | Key parameters | Purpose |
|---|---|---|---|
| `app_open` | App launched/foregrounded | `install_source`, `app_version`, `is_first_open` | Sessions, DAU, source |
| `session_start` | New session begins | `session_id`, `prev_session_gap_min` | Session count, sessions/day |
| `tutorial_step` | Each tutorial step shown/done | `step_index`, `step_name`, `result` | Onboarding funnel drop-off |
| `tutorial_complete` | Tutorial finished | `duration_s`, `steps_total` | Activation (target ≥ 85%) |
| `level_start` | Player begins a level | `level_id`, `sector_id`, `attempt_no`, `sparks_granted`, `lives_remaining` | Funnel, attempt counts |
| `shot_fired` | Spark launched | `level_id`, `shot_index`, `aim_angle`, `power` | Shots/level, aiming behavior |
| `star_lit` | A dim star is lit | `level_id`, `stars_lit`, `stars_total`, `shot_index` | Progress within level |
| `level_complete` | Level cleared | `level_id`, `sector_id`, `stars` (0–3), `sparks_used`, `sparks_granted`, `stardust_collected`, `duration_s`, `boosters_used` | Clear rate, efficiency, difficulty |
| `level_fail` | Out of sparks, stars remain | `level_id`, `sector_id`, `attempt_no`, `stars_lit`, `sparks_used`, `fail_reason` | Difficulty, churn points |
| `restart` | Player restarts a level | `level_id`, `attempt_no`, `reason` | Frustration/retry signal |
| `undo_used` | Rewind/undo invoked | `level_id`, `shot_index` | Booster usage |
| `booster_used` | Booster activated in-level | `booster_id`, `level_id`, `context` (pre/in-level), `source` (coins/stardust/ad/free) | Booster demand & balance |
| `hint_used` | Hint shown | `level_id`, `hint_type` | Difficulty / help demand |
| `sector_unlock` | New sector unlocked | `sector_id`, `total_stars`, `player_level` | Progression depth |
| `level_unlock` | Next level unlocked | `level_id`, `sector_id` | Progression pacing |
| `currency_earned` | Any coin/stardust/XP earned | `currency` (coins/stardust/xp), `amount`, `source`, `balance_after` | Economy sources (`MONETIZATION.md §9`) |
| `currency_spent` | Any coin/stardust spent | `currency`, `amount`, `sink`, `balance_after` | Economy sinks |
| `booster_purchased` | Booster bought (in-game currency) | `booster_id`, `currency`, `price`, `bundle` | Booster monetization |
| `life_refill` | Life(s) refilled | `method` (regen/ad/coins/stardust/iap), `count`, `lives_after` | Lives economy & ad relief |
| `ad_requested` | Ad load requested | `ad_format`, `placement` | Fill rate, request volume |
| `ad_loaded` | Ad ready | `ad_format`, `placement`, `latency_ms` | Load success/latency |
| `ad_shown` | Ad displayed | `ad_format`, `placement` | Impressions |
| `ad_completed` | Ad finished (video) | `ad_format`, `placement`, `watch_pct` | Completion rate |
| `ad_rewarded` | Reward granted | `placement`, `reward_type`, `reward_amount` | Rewarded opt-in & payout |
| `ad_failed` | Ad failed to load/show | `ad_format`, `placement`, `error_code` | Ad reliability |
| `iap_initiated` | Purchase flow started | `product_id`, `price`, `currency`, `entry_point` | IAP funnel top |
| `iap_success` | Purchase completed & validated | `product_id`, `price`, `currency`, `is_first_purchase` | Revenue, conversion |
| `iap_failed` | Purchase failed/cancelled | `product_id`, `error_code`, `stage` | IAP funnel drop-off |
| `remove_ads_purchased` | Remove Ads bought | `product_id`, `price` | Anchor purchase tracking |
| `daily_reward_claimed` | Daily login reward claimed | `streak_day`, `reward_type`, `reward_amount` | Retention loop |
| `streak_updated` | Login/daily streak changes | `streak_day`, `streak_broken` (bool) | Streak health |
| `notification_opened` | Push notification opened | `notification_id`, `campaign` | Re-engagement efficacy |
| `daily_challenge_played` | Daily Challenge attempted | `result`, `stars` | Live-feature engagement |
| `settings_changed` | A setting toggled | `setting`, `value` | Audio/haptics/consent prefs |
| `error_nonfatal` | Caught non-fatal app error | `error_domain`, `error_code`, `context` | Quality (also to Crashlytics) |

> Boss/Supernova finales reuse `level_complete`/`level_fail` with their `level_id` (20/40/60/80/100)
> — no separate event needed.

---

## 4. User properties

Set on the GA4 user for segmentation, audiences, and cohort analysis. Keep ≤ 25 user properties.

| User property | Values / type | Use |
|---|---|---|
| `player_level` | int | Progression segmentation |
| `total_stars` | int | Mastery / completion segmentation |
| `current_sector` | 1–5 | Where players are concentrated |
| `is_payer` | bool | Payer vs. non-payer analysis |
| `ad_remove` | bool | Remove-Ads owners (ad suppression read-out) |
| `install_source` | string | Acquisition channel |
| `ab_cohort` | string | A/B / Remote Config experiment arm |
| `lifetime_value_band` | bucket (ESTIMATE) | LTV banding (minnow/dolphin/whale) |
| `highest_level_cleared` | int | Depth |
| `consent_state` | granted/denied | Privacy gating audit |

---

## 5. Funnels to track

| Funnel | Steps | Watching for |
|---|---|---|
| **Onboarding → activation** | `app_open` (first) → `tutorial_step`(each) → `tutorial_complete` → `level_start`(L1) → `level_complete`(L1) → `sector_unlock`(2) | Tutorial completion ≥ 85%; L1 clear; sector-1 completion |
| **Fail → recover** | `level_fail` → rewarded-ad offer → `ad_shown`(extra_spark) → `ad_rewarded` → `level_complete` | "One more try" loop & rewarded opt-in |
| **Shop → purchase** | shop view → `iap_initiated` → `iap_success` (vs. `iap_failed`) | IAP funnel drop-off, store/price friction |
| **Starter Pack** | offer shown → `iap_initiated`(starterpack) → `iap_success` | Starter conversion (`MONETIZATION.md §10`) |
| **Lives block → relief** | `level_fail` (lives empty) → out-of-lives modal → `life_refill`(method) → `level_start` | Lives friction & ad/IAP relief mix |
| **Daily loop** | `app_open` → `daily_reward_claimed` → `streak_updated` → `daily_challenge_played` | Retention-feature stickiness |
| **Progression depth** | `level_complete` per level → `sector_unlock` per sector | Drop-off levels & difficulty walls |

---

## 6. Retention & engagement metrics

> Definitions and targets; targets mirror `CONCEPT.md §13`.

| Metric | Definition | Target |
|---|---|---|
| **D1 retention** | % of new users returning 1 day after install | **≥ 40%** |
| **D7 retention** | % returning on day 7 | **≥ 18%** |
| **D30 retention** | % returning on day 30 | **≥ 7%** |
| **DAU** | Distinct users active per day | (track) |
| **MAU** | Distinct users active in trailing 30 days | (track) |
| **Stickiness** | DAU ÷ MAU | **≥ 0.20 (ESTIMATE)** |
| **Avg session length** | Mean foreground duration per session | **≥ 6 min** |
| **Sessions/day** | Sessions ÷ DAU | **≥ 3 (engaged)** |
| **Tutorial completion** | `tutorial_complete` ÷ first `app_open` | **≥ 85%** |
| **Churn (D7)** | 1 − D7 retention | **≤ 82%** |

Computed primarily via **BigQuery cohort queries** (GA4 UI for quick reads). Monetization KPIs
(ARPDAU, ARPPU, opt-in, conversion) live in `MONETIZATION.md §10` and are joined to these for
revenue-vs-health context.

---

## 7. Crash & performance reporting

| Area | Tool | Metric / setup | Target |
|---|---|---|---|
| **Crashes** | Crashlytics | Crash-free **sessions** % | **≥ 99.5%** (Concept §13) |
| **Crashes** | Crashlytics | Crash-free **users** % | **≥ 99% (ESTIMATE)** |
| **ANR (Android)** | Crashlytics / Play vitals | ANR rate | **< 0.47%** (Play "bad behavior" threshold) |
| **Frame timing** | Performance Monitoring | Slow frames (>16ms) / frozen frames (>700ms) | **60 FPS on mid-tier**; minimize slow/frozen |
| **App start** | Performance Monitoring | Cold/warm start trace | Fast cold start (Concept §13) |
| **Non-fatals** | Crashlytics + `error_nonfatal` | Logged caught errors | Trend to zero |

**Crashlytics custom keys** (attached to reports for triage): `level_id`, `sector_id`,
`player_level`, `device_tier`, `ab_cohort`, `last_event`, `is_payer`, `ad_remove`,
`memory_warning`. These let us reproduce crashes against the exact level/state.

---

## 8. (reserved — see §9 Dashboards)

---

## 9. Dashboards & reporting cadence

| Dashboard | Contents | Owner | Cadence |
|---|---|---|---|
| **Acquisition & Activation** | Installs, source, tutorial funnel, L1 clear | Growth lead | Daily |
| **Retention** | D1/D7/D30 cohorts, DAU/MAU, stickiness | Growth/Data lead | Daily; cohort review weekly |
| **Engagement & Progression** | Sessions/day, session length, level clear rates, drop-off levels | Game design + Data | Weekly |
| **Difficulty** | Per-level clear rate, attempts, restarts, fails, sparks_used distribution | Level design | Per content update + weekly |
| **Economy** | Currency sources/sinks, coin/stardust balance over time, lives-empty rate | Monetization/Data | Weekly |
| **Monetization** | ARPDAU, ad/IAP split, opt-in, conversion, eCPM, A/B read-outs | Monetization lead | Daily (revenue) / weekly (deep) |
| **Quality** | Crash-free %, ANR, frame timing, non-fatals | Eng lead | Daily |
| **Experiments** | Active A/B arms vs. guardrails | Growth/Data | Per experiment + weekly |

- **Daily standup read:** revenue, DAU, crash-free, any guardrail breach.
- **Weekly review:** retention cohorts, economy health, difficulty outliers, experiment decisions.
- **Per-release / content drop:** difficulty + funnel re-check before wide rollout.
- Built in **Looker Studio** over **GA4 + BigQuery**; raw economy/LTV modeling in BigQuery SQL.

---

## 10. Privacy & consent

- **Consent-gated analytics:** analytics collection (beyond strictly necessary) and ad
  personalization are **gated on the UMP/consent flow** (`MONETIZATION.md §11`). When consent is
  denied, set GA4 **Consent Mode** to denied, disable advertising identifiers, and fall back to
  aggregated/cookieless signals. `consent_state` user property records the choice.
- **GDPR / CCPA:** honor data-subject requests (access/delete) via Firebase user-data deletion;
  expose a privacy/consent toggle in settings (`settings_changed`); document processing in the
  privacy policy.
- **COPPA / children:** if the user is child-directed or under age of consent, **disable
  personalized ads and restrict analytics** (no advertising ID, minimal events), mirroring the
  ad-side tags in `MONETIZATION.md §11`.
- **Anonymization:** no PII in events or user properties — use anonymous Firebase Auth IDs only;
  enable **IP anonymization**; never log emails, names, or precise location. Disable Google
  Signals / ad-personalization data sharing where consent is absent.
- **Data retention:** set GA4 event-data retention to the minimum that supports our cohort
  analysis (e.g. **14 months**); rely on **BigQuery** for longer historical modeling with access
  controls; define a BigQuery table-expiration/retention policy.
- **Transparency:** disclose analytics, crash reporting, and ads in the store data-safety /
  privacy-nutrition labels and the in-app privacy policy; keep them accurate to the events above.

---

*End of ANALYTICS.md — targets mirror `CONCEPT.md §13`; estimates labeled ESTIMATE. Feeds the
telemetry-driven tuning loop in `MONETIZATION.md §9`.*
