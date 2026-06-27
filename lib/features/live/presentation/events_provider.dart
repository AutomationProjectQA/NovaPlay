import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/live/domain/game_event.dart';
import 'package:novaplay/features/rewards/domain/daily_reward.dart';

/// The currently active live event (seasonal banner / weekend bonus).
final activeEventProvider = Provider<GameEvent>((ref) {
  final now = DateTime.now();
  return activeEvent(
    today: epochDay(now.millisecondsSinceEpoch),
    weekday: now.weekday,
  );
});
