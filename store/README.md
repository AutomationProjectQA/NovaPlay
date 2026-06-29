# store/ — Store listing source of truth

Version-controlled store assets and metadata for NovaPlay, structured for
**fastlane** (`supply` for Google Play, `deliver` for the App Store) so listings
are reproducible and reviewable in PRs instead of hand-edited in consoles.

```
store/
  metadata/
    android/<locale>/        # fastlane supply layout
      title.txt              # ≤ 30 chars
      short_description.txt  # ≤ 80 chars
      full_description.txt   # ≤ 4000 chars
      changelogs/default.txt # release notes
    ios/<locale>/            # fastlane deliver layout
      name.txt               # ≤ 30 chars
      subtitle.txt           # ≤ 30 chars
      keywords.txt           # ≤ 100 chars, comma-separated
      description.txt        # ≤ 4000 chars
      promotional_text.txt   # ≤ 170 chars (editable without review)
      release_notes.txt
  screenshots/               # capture recipe + device matrix (see its README)
```

Locales: `en-US`, `es-ES`, `ar` (Play) / `ar-SA` (App Store) — matching the
in-app locales (docs/LOCALIZATION.md).

The human-readable rationale, ASO keyword strategy, and character-limit table
live in [docs/STORE_LISTING.md](../docs/STORE_LISTING.md). The pipeline that
uploads these lives in [docs/RELEASE_PLAN.md](../docs/RELEASE_PLAN.md) §6.

> Edit the `.txt` files here, not the store consoles — the consoles are
> overwritten on the next `fastlane` run.
