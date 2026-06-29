/// Remote kill switch / forced-update logic (docs/LIVEOPS.md). Driven by the
/// Remote Config values `min_supported_build` and `latest_build` so a broken
/// build can be blocked, or an update nudged, without shipping a new binary.
enum UpdateStatus {
  /// Running the latest (or newer) build — play freely.
  upToDate,

  /// A newer build exists; show a dismissible nudge.
  updateAvailable,

  /// Below the minimum supported build — block play until updated.
  updateRequired,
}

/// Pure evaluation of the current build against the server thresholds.
/// `updateRequired` wins over `updateAvailable`. A [latestBuild] of 0 (unset)
/// disables the soft nudge.
UpdateStatus evaluateUpdate({
  required int currentBuild,
  required int minSupportedBuild,
  int latestBuild = 0,
}) {
  if (currentBuild < minSupportedBuild) return UpdateStatus.updateRequired;
  if (latestBuild > currentBuild) return UpdateStatus.updateAvailable;
  return UpdateStatus.upToDate;
}
