# Release tooling (fastlane)

Lanes live in `android/fastlane/` and `ios/fastlane/`; both read the localized
listing from `store/metadata/`. Install once with `bundle install`.

Common commands (run from the platform dir):

    cd android && bundle exec fastlane beta       # Play internal track
    cd android && bundle exec fastlane release    # Play production (10% rollout)
    cd android && bundle exec fastlane metadata   # push listing text only

    cd ios && bundle exec fastlane beta           # TestFlight
    cd ios && bundle exec fastlane release        # App Store (no auto-submit)

Required secrets/env (set in CI — never commit):
- Android: `PLAY_JSON_KEY_FILE` (service-account JSON), plus the signing secrets
  consumed by `key.properties` (RELEASE_PLAN §4).
- iOS: `APPLE_ID`, `APPLE_TEAM_ID`, `APP_STORE_CONNECT_API_KEY`.

See docs/RELEASE_PLAN.md §6 for the full pipeline.
