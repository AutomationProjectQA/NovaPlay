import 'dart:ui';

import 'package:equatable/equatable.dart';

/// One of the five galaxy sectors (docs/CONCEPT.md §6). Carries display info and
/// the player's progress within it.
class Sector extends Equatable {
  const Sector({
    required this.id,
    required this.name,
    required this.accent,
    required this.firstLevel,
    required this.lastLevel,
    required this.starsEarned,
    required this.unlocked,
  });

  final int id;
  final String name;
  final Color accent;
  final int firstLevel;
  final int lastLevel;
  final int starsEarned;
  final bool unlocked;

  int get levelCount => lastLevel - firstLevel + 1;

  /// Max stars obtainable in this sector (3 per level).
  int get starsTotal => levelCount * 3;

  double get progress => starsTotal == 0 ? 0 : starsEarned / starsTotal;

  @override
  List<Object?> get props => [
    id,
    name,
    accent,
    firstLevel,
    lastLevel,
    starsEarned,
    unlocked,
  ];
}
