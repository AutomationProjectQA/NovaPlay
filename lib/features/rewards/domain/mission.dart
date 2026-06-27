import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';

/// What a daily mission measures.
enum MissionMetric { levelsCleared, starsEarned }

/// A daily mission (docs/MONETIZATION.md §8, GAME_DESIGN retention). Progress is
/// tracked against a per-day counter and reset each day.
class Mission {
  const Mission({
    required this.id,
    required this.label,
    required this.metric,
    required this.target,
    required this.reward,
  });

  final String id;
  final String label;
  final MissionMetric metric;
  final int target;
  final Reward reward;
}

/// The three daily missions.
const List<Mission> kDailyMissions = [
  Mission(
    id: 'clear3',
    label: 'Clear 3 levels',
    metric: MissionMetric.levelsCleared,
    target: 3,
    reward: Reward(coins: 40),
  ),
  Mission(
    id: 'stars6',
    label: 'Earn 6 stars',
    metric: MissionMetric.starsEarned,
    target: 6,
    reward: Reward(coins: 50),
  ),
  Mission(
    id: 'clear5',
    label: 'Clear 5 levels',
    metric: MissionMetric.levelsCleared,
    target: 5,
    reward: Reward(coins: 60, boosters: {BoosterType.rewind: 1}),
  ),
];

/// A mission with its current progress and claim state.
class MissionState {
  const MissionState({
    required this.mission,
    required this.progress,
    required this.claimed,
  });

  final Mission mission;
  final int progress;
  final bool claimed;

  bool get isComplete => progress >= mission.target;
  bool get canClaim => isComplete && !claimed;
  double get fraction =>
      mission.target == 0 ? 0 : (progress / mission.target).clamp(0.0, 1.0);
}
