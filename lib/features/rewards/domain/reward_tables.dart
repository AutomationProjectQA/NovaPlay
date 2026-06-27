import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/domain/reward_roller.dart';

/// Lucky Wheel prize table (docs/MONETIZATION.md §8). Weighted; small jackpot.
const List<WeightedReward> kWheelRewards = [
  WeightedReward(Reward(coins: 20), 30),
  WeightedReward(Reward(coins: 50), 25),
  WeightedReward(Reward(coins: 100), 15),
  WeightedReward(Reward(stardust: 2), 10),
  WeightedReward(Reward(boosters: {BoosterType.rewind: 1}), 10),
  WeightedReward(Reward(boosters: {BoosterType.extraSpark: 1}), 7),
  WeightedReward(Reward(coins: 250), 3),
];

/// Mystery Chest prize table — richer than the wheel, opened less often.
const List<WeightedReward> kChestRewards = [
  WeightedReward(Reward(coins: 50), 30),
  WeightedReward(Reward(coins: 120), 25),
  WeightedReward(Reward(boosters: {BoosterType.slowMo: 1}), 15),
  WeightedReward(Reward(stardust: 3), 15),
  WeightedReward(Reward(boosters: {BoosterType.extraSpark: 1}), 10),
  WeightedReward(Reward(coins: 300, stardust: 5), 5),
];
