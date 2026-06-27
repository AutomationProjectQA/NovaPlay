import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';

/// What an achievement measures (derived from saved progress).
enum AchievementMetric { levelsCleared, totalStars, threeStarLevels }

/// A one-time achievement (docs/UI_GUIDELINES.md §3.9). Auto-evaluated from
/// progress; the reward is claimed once unlocked.
class Achievement {
  const Achievement({
    required this.id,
    required this.label,
    required this.metric,
    required this.target,
    required this.reward,
  });

  final String id;
  final String label;
  final AchievementMetric metric;
  final int target;
  final Reward reward;
}

/// The achievement set.
const List<Achievement> kAchievements = [
  Achievement(
    id: 'first_light',
    label: 'First Light — clear a level',
    metric: AchievementMetric.levelsCleared,
    target: 1,
    reward: Reward(coins: 20),
  ),
  Achievement(
    id: 'pathfinder',
    label: 'Pathfinder — clear 10 levels',
    metric: AchievementMetric.levelsCleared,
    target: 10,
    reward: Reward(coins: 50),
  ),
  Achievement(
    id: 'voyager',
    label: 'Voyager — clear 25 levels',
    metric: AchievementMetric.levelsCleared,
    target: 25,
    reward: Reward(coins: 100, stardust: 2),
  ),
  Achievement(
    id: 'stargazer',
    label: 'Stargazer — earn 30 stars',
    metric: AchievementMetric.totalStars,
    target: 30,
    reward: Reward(coins: 60),
  ),
  Achievement(
    id: 'collector',
    label: 'Collector — earn 100 stars',
    metric: AchievementMetric.totalStars,
    target: 100,
    reward: Reward(coins: 150, stardust: 5),
  ),
  Achievement(
    id: 'perfectionist',
    label: 'Perfectionist — 3-star 5 levels',
    metric: AchievementMetric.threeStarLevels,
    target: 5,
    reward: Reward(coins: 80, boosters: {BoosterType.extraSpark: 1}),
  ),
];

/// An achievement with its current progress + claim state.
class AchievementState {
  const AchievementState({
    required this.achievement,
    required this.progress,
    required this.claimed,
  });

  final Achievement achievement;
  final int progress;
  final bool claimed;

  bool get isUnlocked => progress >= achievement.target;
  bool get canClaim => isUnlocked && !claimed;
  double get fraction => achievement.target == 0
      ? 0
      : (progress / achievement.target).clamp(0.0, 1.0);
}

/// Computes the metric values from a `levelId -> stars` progress map.
Map<AchievementMetric, int> achievementMetrics(Map<int, int> progress) {
  var cleared = 0;
  var stars = 0;
  var threeStar = 0;
  for (final value in progress.values) {
    if (value > 0) cleared++;
    stars += value;
    if (value >= 3) threeStar++;
  }
  return {
    AchievementMetric.levelsCleared: cleared,
    AchievementMetric.totalStars: stars,
    AchievementMetric.threeStarLevels: threeStar,
  };
}
