import 'dart:math';

import 'package:novaplay/features/rewards/domain/reward.dart';

/// A weighted reward entry for a randomized opener (wheel / chest).
class WeightedReward {
  const WeightedReward(this.reward, this.weight);

  final Reward reward;
  final int weight;
}

/// Picks one [Reward] from [entries] using their weights. Pure — pass a seeded
/// [Random] for deterministic tests.
Reward rollReward(List<WeightedReward> entries, Random random) {
  final total = entries.fold<int>(0, (sum, e) => sum + e.weight);
  if (total <= 0) return const Reward();
  var roll = random.nextInt(total);
  for (final entry in entries) {
    if (roll < entry.weight) return entry.reward;
    roll -= entry.weight;
  }
  return entries.last.reward;
}
