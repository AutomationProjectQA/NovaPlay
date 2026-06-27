import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/domain/mission.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

/// Raw daily mission state: per-metric counters + claimed mission ids.
class MissionsData {
  const MissionsData({required this.counters, required this.claimed});

  final Map<MissionMetric, int> counters;
  final Set<String> claimed;
}

final missionsProvider = NotifierProvider<MissionsNotifier, MissionsData>(
  MissionsNotifier.new,
);

class MissionsNotifier extends Notifier<MissionsData> {
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);
  int get _today => todayEpochDay();

  @override
  MissionsData build() {
    _ensureToday();
    return _load();
  }

  /// Resets daily counters/claims when the day rolls over.
  void _ensureToday() {
    if (_repo.missionDay == _today) return;
    unawaited(_repo.setMissionDay(_today));
    for (final metric in MissionMetric.values) {
      unawaited(_repo.setMissionCounter(metric.name, 0));
    }
    unawaited(_repo.setMissionsClaimed(const []));
  }

  MissionsData _load() => MissionsData(
    counters: {
      for (final metric in MissionMetric.values)
        metric: _repo.missionCounter(metric.name),
    },
    claimed: _repo.missionsClaimed.toSet(),
  );

  /// Records a level win toward the daily missions.
  void recordLevelCleared(int stars) {
    _ensureToday();
    final counters = {...state.counters};
    counters[MissionMetric.levelsCleared] =
        (counters[MissionMetric.levelsCleared] ?? 0) + 1;
    counters[MissionMetric.starsEarned] =
        (counters[MissionMetric.starsEarned] ?? 0) + stars;
    for (final entry in counters.entries) {
      unawaited(_repo.setMissionCounter(entry.key.name, entry.value));
    }
    state = MissionsData(counters: counters, claimed: state.claimed);
  }

  /// Claims a completed mission; returns false if not completable.
  bool claim(String id) {
    final mission = kDailyMissions.firstWhere((m) => m.id == id);
    final progress = state.counters[mission.metric] ?? 0;
    if (progress < mission.target || state.claimed.contains(id)) return false;
    applyReward(ref, mission.reward);
    final claimed = {...state.claimed, id};
    unawaited(_repo.setMissionsClaimed(claimed.toList()));
    state = MissionsData(counters: state.counters, claimed: claimed);
    return true;
  }
}

/// The daily missions with progress + claim state for the UI.
final dailyMissionStatesProvider = Provider<List<MissionState>>((ref) {
  final data = ref.watch(missionsProvider);
  return [
    for (final mission in kDailyMissions)
      MissionState(
        mission: mission,
        progress: data.counters[mission.metric] ?? 0,
        claimed: data.claimed.contains(mission.id),
      ),
  ];
});
