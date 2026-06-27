import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';

/// The bonus for completing the Daily Challenge (docs/GAME_DESIGN.md retention,
/// MONETIZATION.md §8: 50 coins once per day).
const Reward kDailyChallengeReward = Reward(
  coins: 50,
  boosters: {BoosterType.extraSpark: 1},
);

/// The featured level for a given epoch-[day] — deterministic so everyone gets
/// the same challenge, rotating through the catalog.
int challengeLevelId(int day) => (day % kTotalLevels) + 1;
