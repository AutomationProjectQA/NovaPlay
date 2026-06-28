/// Pure interstitial frequency rules (docs/MONETIZATION.md §2 ad strategy:
/// frequency-capped, never in the first sessions, never mid-level).
abstract final class AdFrequency {
  /// No interstitials before the player has cleared a few levels.
  static const int minLevelToStartAds = 4;

  /// Whether an interstitial should run after completing [currentLevel], given
  /// how many levels have passed since the last ad ([levelsSinceLastAd]) and the
  /// server-tuned [everyN] cadence.
  static bool shouldShowInterstitial({
    required int currentLevel,
    required int levelsSinceLastAd,
    required int everyN,
  }) {
    if (currentLevel < minLevelToStartAds) return false;
    if (everyN <= 0) return false;
    return levelsSinceLastAd >= everyN;
  }
}
