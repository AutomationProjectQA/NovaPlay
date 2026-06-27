import 'dart:ui';

import 'package:novaplay/app/theme/app_colors.dart';

/// A live/seasonal event (docs/GAME_DESIGN.md retention). For now events are
/// derived locally from the calendar; they'd be Remote Config-driven in
/// production. [coinMultiplier] scales level-clear coin rewards.
class GameEvent {
  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.accent,
    this.coinMultiplier = 1,
  });

  final String id;
  final String title;
  final String description;
  final Color accent;
  final int coinMultiplier;

  bool get hasBonus => coinMultiplier > 1;
}

const GameEvent _doubleCoins = GameEvent(
  id: 'double_coins',
  title: 'Double Coins Weekend',
  description: 'All level rewards pay out double. Light it up!',
  accent: AppColors.nova500,
  coinMultiplier: 2,
);

const List<GameEvent> _seasonal = [
  GameEvent(
    id: 'nebula_festival',
    title: 'Nebula Festival',
    description: 'Drift through the violet clouds of the Nebula sector.',
    accent: AppColors.sectorNebula,
  ),
  GameEvent(
    id: 'pulsar_rush',
    title: 'Pulsar Rush',
    description: 'A rhythmic week among the pulsing stars.',
    accent: AppColors.sectorPulsar,
  ),
  GameEvent(
    id: 'void_carnival',
    title: 'Void Carnival',
    description: 'Dare the dark — black holes and wormholes await.',
    accent: AppColors.sectorVoid,
  ),
];

/// The active event for [today] (epoch-day) and [weekday] (1=Mon … 7=Sun).
/// Weekends run Double Coins; weekdays rotate the seasonal banner weekly.
GameEvent activeEvent({required int today, required int weekday}) {
  if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
    return _doubleCoins;
  }
  return _seasonal[(today ~/ 7) % _seasonal.length];
}
