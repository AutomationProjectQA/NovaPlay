/// Pure decision logic for when to surface the native "rate this app" prompt
/// (docs/RELEASE_PLAN.md ASO). The OS itself rate-limits the real dialog
/// (iOS ~3×/year), so this is the app-side politeness layer: only ask a happy,
/// invested player, only at a winning moment, and never nag.
abstract final class ReviewGate {
  /// Don't ask until the player has cleared enough levels to have an opinion.
  static const int minLevelsCleared = 5;

  /// Levels that must pass after a prompt before we may ask again.
  static const int cooldownLevels = 20;

  /// Whether to request a review now, given how many levels the player has
  /// cleared, the [lastPromptLevel] (0 = never asked), and whether they've
  /// [alreadyReviewed]. Call only at a positive beat (a level win).
  static bool shouldRequestReview({
    required int levelsCleared,
    required int lastPromptLevel,
    required bool alreadyReviewed,
    int minLevels = minLevelsCleared,
    int cooldown = cooldownLevels,
  }) {
    if (alreadyReviewed) return false;
    if (levelsCleared < minLevels) return false;
    // First-ever prompt is allowed once the minimum is met; subsequent prompts
    // wait out the cooldown so we never ask twice in quick succession.
    if (lastPromptLevel != 0 && levelsCleared - lastPromptLevel < cooldown) {
      return false;
    }
    return true;
  }
}
