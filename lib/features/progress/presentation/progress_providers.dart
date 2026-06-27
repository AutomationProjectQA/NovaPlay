import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/progress/data/progress_repository.dart';

/// Total handcrafted levels in the game (docs/CONCEPT.md §6).
const int kTotalLevels = 100;

/// Provides the progress persistence implementation.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(progressBox());
});

/// The player's best stars per level (`levelId -> stars`). The single source of
/// truth for unlock state and star totals across the app.
final progressProvider = NotifierProvider<ProgressNotifier, Map<int, int>>(
  ProgressNotifier.new,
);

/// Mutates and persists per-level best stars.
class ProgressNotifier extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => ref.read(progressRepositoryProvider).loadAll();

  /// Records a level result, keeping the best star count. No-op on a loss or a
  /// non-improving result.
  void recordResult({required int levelId, required int stars}) {
    if (stars <= 0) return;
    final current = state[levelId] ?? 0;
    if (stars <= current) return;
    final next = {...state, levelId: stars};
    state = next;
    unawaited(ref.read(progressRepositoryProvider).saveAll(next));
  }

  /// Best stars for a level, or 0.
  int starsFor(int levelId) => state[levelId] ?? 0;
}

/// The next playable level: one past the highest cleared level
/// (sequential unlock, docs/CONCEPT.md §6). Starts at 1.
final highestUnlockedLevelProvider = Provider<int>((ref) {
  final progress = ref.watch(progressProvider);
  var maxCleared = 0;
  for (final entry in progress.entries) {
    if (entry.value > 0 && entry.key > maxCleared) maxCleared = entry.key;
  }
  return (maxCleared + 1).clamp(1, kTotalLevels);
});

/// Total stars earned across all levels.
final totalStarsProvider = Provider<int>((ref) {
  return ref.watch(progressProvider).values.fold(0, (sum, s) => sum + s);
});
