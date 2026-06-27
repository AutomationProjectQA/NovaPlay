import 'package:equatable/equatable.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';

/// The player's XP and derived level (docs/MONETIZATION.md §3.4). XP is pure
/// progression — never spent or bought.
class PlayerXp extends Equatable {
  const PlayerXp({
    required this.totalXp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// Derives level + within-level progress from a total XP value using the
  /// `XP_to_next = 100 + level × 50` curve.
  factory PlayerXp.fromTotal(int totalXp) {
    var level = 1;
    var remaining = totalXp;
    var needed = EconomyConfig.xpForNextLevel(level);
    while (remaining >= needed) {
      remaining -= needed;
      level++;
      needed = EconomyConfig.xpForNextLevel(level);
    }
    return PlayerXp(
      totalXp: totalXp,
      level: level,
      xpIntoLevel: remaining,
      xpForNextLevel: needed,
    );
  }

  final int totalXp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  /// Progress toward the next level, 0–1.
  double get progress => xpForNextLevel == 0 ? 0 : xpIntoLevel / xpForNextLevel;

  @override
  List<Object?> get props => [totalXp, level, xpIntoLevel, xpForNextLevel];
}
