# PRIVACY.md — Data collection, store privacy labels & manifests

> Sprint 21 deliverable. The single source of truth for what NovaPlay collects
> and how that maps to the **Google Play Data Safety** form, the **App Store
> Privacy "nutrition label"**, and Apple's **privacy manifest**
> ([`ios/Runner/PrivacyInfo.xcprivacy`](../ios/Runner/PrivacyInfo.xcprivacy)).
> Keep all three in sync with this file.

## 1. What NovaPlay collects

| Data | Why | Linked to identity | Used for tracking | Source |
|---|---|---|---|---|
| Crash logs & diagnostics | Stability | No | No | Crashlytics (when wired) |
| Product interaction (gameplay events) | Anonymous analytics | No | No | GA4 (when wired) |
| Approximate ad data | Show ads | No | Not by default | AdMob (non-personalized by default) |
| Game progress, settings, wallet | Core gameplay | No | No | **On-device only** (Hive); not transmitted |

NovaPlay does **not** collect name, email, contacts, precise location, photos, or
device identifiers for cross-app tracking. There is **no account/login**. All
progress lives on-device until an opt-in cloud-save is added.

> The analytics/crash/ads SDKs are currently **stubbed** (SETUP.md); nothing is
> transmitted until they are connected. Update this table and the forms the moment
> a real SDK is wired.

## 2. Google Play — Data Safety form

- **Data collected:** Crash logs (App functionality), App interactions
  (Analytics). **Data shared:** none beyond the ad/analytics processors.
- **Encrypted in transit:** Yes. **Users can request deletion:** Yes (no account;
  uninstalling clears on-device data — provide a support contact for any
  server-side analytics deletion).
- **Not for tracking:** ad data is non-personalized by default; if personalized
  ads are enabled later, update the form and gate behind consent (UMP).

## 3. App Store — Privacy nutrition label

- **Data Not Linked to You:** Crash Data, Product Interaction.
- **Data Used to Track You:** none (matches `NSPrivacyTracking = false`).
- If personalized ads are enabled later, AdMob moves "Identifiers / Usage Data"
  into **Used to Track**, which **requires App Tracking Transparency** (ATT)
  prompt + `NSUserTrackingUsageDescription` in Info.plist.

## 4. Apple privacy manifest

`ios/Runner/PrivacyInfo.xcprivacy` declares:
- `NSPrivacyTracking = false`, no tracking domains.
- Collected types: **Crash Data**, **Product Interaction** (both not-linked,
  not-tracking).
- Required-reason APIs in use by dependencies:
  - **UserDefaults** — `CA92.1` (shared_preferences / settings).
  - **File timestamp** — `C617.1` (path_provider / Hive).
  - **Disk space** — `E174.1`.

> ⚠️ Add the manifest to the **Runner** target in Xcode (Build Phases → Copy
> Bundle Resources) so it ships in the IPA. Re-audit when adding any SDK — Firebase
> and AdMob also ship their own manifests that Apple aggregates.

## 5. Required documents before submission

- [ ] Hosted **Privacy Policy** URL (both stores require it; link from Settings →
  Privacy · Terms, which is already in the UI).
- [ ] Hosted **Terms of Service** URL.
- [ ] Content rating questionnaires (Play IARC + App Store age rating) — expected
  rating **Everyone / 4+** (no objectionable content; ads present).
- [ ] Account deletion / data deletion contact (even without accounts, stores ask).

See [RELEASE_PLAN.md](RELEASE_PLAN.md) §2 for the full pre-release checklist.
