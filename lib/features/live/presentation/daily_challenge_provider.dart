import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/live/domain/daily_challenge.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

/// Today's daily challenge state.
class ChallengeStatus {
  const ChallengeStatus({required this.levelId, required this.doneToday});

  final int levelId;
  final bool doneToday;
}

final dailyChallengeProvider =
    NotifierProvider<DailyChallengeNotifier, ChallengeStatus>(
      DailyChallengeNotifier.new,
    );

class DailyChallengeNotifier extends Notifier<ChallengeStatus> {
  RewardsRepository get _repo => ref.read(rewardsRepositoryProvider);
  int get _today => todayEpochDay();

  @override
  ChallengeStatus build() => ChallengeStatus(
    levelId: challengeLevelId(_today),
    doneToday: _repo.challengeLastDay == _today && _repo.challengeLastDay != 0,
  );

  /// If [levelId] is today's challenge and it isn't done yet, grants the bonus.
  void completeIfMatches(int levelId) {
    if (state.doneToday || levelId != state.levelId) return;
    applyReward(ref, kDailyChallengeReward);
    unawaited(_repo.setChallengeLastDay(_today));
    state = ChallengeStatus(levelId: state.levelId, doneToday: true);
  }
}
