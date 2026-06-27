import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/progress/data/progress_repository.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// Builds a container with an in-memory progress repo (no Hive) and an optional
/// seeded star map.
ProviderContainer _container([Map<int, int> seed = const {}]) {
  final container = ProviderContainer(
    overrides: [
      progressRepositoryProvider.overrideWithValue(ProgressRepository(null)),
    ],
  );
  if (seed.isNotEmpty) {
    final notifier = container.read(progressProvider.notifier);
    for (final entry in seed.entries) {
      notifier.recordResult(levelId: entry.key, stars: entry.value);
    }
  }
  return container;
}

void main() {
  group('ProgressNotifier', () {
    test('records stars and keeps the best result', () {
      final container = _container();
      addTearDown(container.dispose);
      final notifier = container.read(progressProvider.notifier)
        ..recordResult(levelId: 1, stars: 2)
        ..recordResult(levelId: 1, stars: 1) // worse — ignored
        ..recordResult(levelId: 1, stars: 3); // better — kept
      expect(notifier.starsFor(1), 3);
    });

    test('a loss (0 stars) records nothing', () {
      final container = _container();
      addTearDown(container.dispose);
      container
          .read(progressProvider.notifier)
          .recordResult(
            levelId: 5,
            stars: 0,
          );
      expect(container.read(progressProvider), isEmpty);
    });
  });

  group('derived providers', () {
    test('highestUnlockedLevel is one past the highest cleared level', () {
      final container = _container({1: 3, 2: 2, 3: 1});
      addTearDown(container.dispose);
      expect(container.read(highestUnlockedLevelProvider), 4);
    });

    test('with no progress, only level 1 is unlocked', () {
      final container = _container();
      addTearDown(container.dispose);
      expect(container.read(highestUnlockedLevelProvider), 1);
    });

    test('totalStars sums all earned stars', () {
      final container = _container({1: 3, 2: 2, 25: 1});
      addTearDown(container.dispose);
      expect(container.read(totalStarsProvider), 6);
    });

    test('sectors reflect stars-in-range and sequential unlock', () {
      final container = _container({1: 3, 2: 3, 3: 3}); // 9 stars in sector 1
      addTearDown(container.dispose);
      final sectors = container.read(sectorsProvider);
      expect(sectors.first.starsEarned, 9);
      expect(sectors.first.unlocked, isTrue);
      // Highest unlocked is 4 → still inside sector 1, so sector 2 stays locked.
      expect(sectors[1].unlocked, isFalse);
    });
  });
}
