import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';

/// Milliseconds in a day, for epoch-day math.
const int kMsPerDay = 86400000;

/// Converts an epoch-millis timestamp to a whole epoch-day index.
int epochDay(int epochMs) => epochMs ~/ kMsPerDay;

/// The 7-day login reward ladder (docs/MONETIZATION.md §3.1, §8). Coins scale
/// with the streak day; later days add boosters / stardust.
const List<Reward> kDailyLadder = [
  Reward(coins: 20),
  Reward(coins: 30),
  Reward(coins: 40, boosters: {BoosterType.rewind: 1}),
  Reward(coins: 50),
  Reward(coins: 60),
  Reward(coins: 80, boosters: {BoosterType.extraSpark: 1}),
  Reward(coins: 100, stardust: 5, boosters: {BoosterType.slowMo: 1}),
];

/// The evaluated daily-reward state for the current day.
class DailyStatus {
  const DailyStatus({
    required this.canClaim,
    required this.streak,
    required this.claimDay,
    required this.reward,
  });

  /// True if the player can claim today.
  final bool canClaim;

  /// The current (already-credited) streak length.
  final int streak;

  /// The 1-based ladder day that would be claimed now (1–7).
  final int claimDay;

  /// The reward for [claimDay].
  final Reward reward;
}

/// Pure daily-reward evaluation. Given the stored [lastClaimDay], the credited
/// [streak], and [today] (all epoch-days), determines whether a claim is
/// available and what it grants — handling first-claim, consecutive days, and
/// missed-day resets.
DailyStatus evaluateDaily({
  required int lastClaimDay,
  required int streak,
  required int today,
}) {
  final alreadyClaimed = lastClaimDay == today && lastClaimDay != 0;
  final consecutive = lastClaimDay == today - 1;
  final nextStreak = alreadyClaimed ? streak : (consecutive ? streak + 1 : 1);
  final claimDay = ((nextStreak - 1) % kDailyLadder.length) + 1;
  return DailyStatus(
    canClaim: !alreadyClaimed,
    streak: alreadyClaimed ? streak : streak,
    claimDay: claimDay,
    reward: kDailyLadder[claimDay - 1],
  );
}
