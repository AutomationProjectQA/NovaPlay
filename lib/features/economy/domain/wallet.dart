import 'package:equatable/equatable.dart';

/// The player's spendable balances (docs/CONCEPT.md §7).
class Wallet extends Equatable {
  const Wallet({this.coins = 0, this.stardust = 0});

  final int coins;
  final int stardust;

  bool canAfford(int coinCost) => coins >= coinCost;

  Wallet copyWith({int? coins, int? stardust}) =>
      Wallet(coins: coins ?? this.coins, stardust: stardust ?? this.stardust);

  @override
  List<Object?> get props => [coins, stardust];
}

/// The lives/energy gate (docs/CONCEPT.md §7): regenerates over time up to [max].
class Lives extends Equatable {
  const Lives({this.current = 5, this.max = 5, this.nextRegen});

  final int current;
  final int max;

  /// Time until the next life regenerates; null when full.
  final Duration? nextRegen;

  bool get isFull => current >= max;
  bool get isEmpty => current <= 0;

  @override
  List<Object?> get props => [current, max, nextRegen];
}
