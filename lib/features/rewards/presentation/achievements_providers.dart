import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/domain/achievement.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

/// The set of claimed achievement ids.
final achievementsProvider =
    NotifierProvider<AchievementsNotifier, Set<String>>(
      AchievementsNotifier.new,
    );

class AchievementsNotifier extends Notifier<Set<String>> {
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);

  @override
  Set<String> build() => _repo.achievementsClaimed.toSet();

  /// Claims an unlocked achievement; returns false if not claimable.
  bool claim(String id) {
    final achievement = kAchievements.firstWhere((a) => a.id == id);
    final metrics = achievementMetrics(ref.read(progressProvider));
    final progress = metrics[achievement.metric] ?? 0;
    if (progress < achievement.target || state.contains(id)) return false;
    applyReward(ref, achievement.reward);
    final claimed = {...state, id};
    unawaited(_repo.setAchievementsClaimed(claimed.toList()));
    state = claimed;
    return true;
  }
}

/// All achievements with live progress + claim state for the UI.
final achievementStatesProvider = Provider<List<AchievementState>>((ref) {
  final metrics = achievementMetrics(ref.watch(progressProvider));
  final claimed = ref.watch(achievementsProvider);
  return [
    for (final achievement in kAchievements)
      AchievementState(
        achievement: achievement,
        progress: metrics[achievement.metric] ?? 0,
        claimed: claimed.contains(achievement.id),
      ),
  ];
});
