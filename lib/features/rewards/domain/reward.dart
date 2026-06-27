import 'package:equatable/equatable.dart';
import 'package:novaplay/features/economy/domain/booster.dart';

/// A bundle of things a reward can grant (docs/MONETIZATION.md §8). Applied to
/// the economy by `applyReward`.
class Reward extends Equatable {
  const Reward({this.coins = 0, this.stardust = 0, this.boosters = const {}});

  final int coins;
  final int stardust;
  final Map<BoosterType, int> boosters;

  bool get isEmpty => coins == 0 && stardust == 0 && boosters.isEmpty;

  /// A short human-readable summary, e.g. "120 coins · 1 Extra Spark".
  String get summary {
    final parts = <String>[
      if (coins > 0) '$coins coins',
      if (stardust > 0) '$stardust stardust',
      for (final entry in boosters.entries)
        if (entry.value > 0) '${entry.value} ${entry.key.label}',
    ];
    return parts.isEmpty ? 'Nothing' : parts.join(' · ');
  }

  @override
  List<Object?> get props => [coins, stardust, boosters];
}
