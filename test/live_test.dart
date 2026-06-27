import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/leaderboard_service.dart';
import 'package:novaplay/features/economy/data/economy_repository.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/live/domain/daily_challenge.dart';
import 'package:novaplay/features/live/domain/game_event.dart';
import 'package:novaplay/features/live/presentation/daily_challenge_provider.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/rewards/data/rewards_repository.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      rewardsRepositoryProvider.overrideWithValue(RewardsRepository(null)),
      economyRepositoryProvider.overrideWithValue(EconomyRepository(null)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('challengeLevelId', () {
    test('rotates deterministically through the catalog', () {
      expect(challengeLevelId(0), 1);
      expect(challengeLevelId(99), 100);
      expect(challengeLevelId(kTotalLevels), 1);
    });
  });

  group('DailyChallengeNotifier', () {
    test('completing the featured level grants the bonus once', () {
      final container = _container();
      final notifier = container.read(dailyChallengeProvider.notifier);
      final todaysLevel = container.read(dailyChallengeProvider).levelId;

      // A non-matching level does nothing.
      notifier.completeIfMatches(todaysLevel == 1 ? 2 : 1);
      expect(container.read(dailyChallengeProvider).doneToday, isFalse);

      final before = container.read(walletProvider).coins;
      notifier.completeIfMatches(todaysLevel);
      expect(container.read(dailyChallengeProvider).doneToday, isTrue);
      expect(container.read(walletProvider).coins, greaterThan(before));

      // No double reward.
      final after = container.read(walletProvider).coins;
      notifier.completeIfMatches(todaysLevel);
      expect(container.read(walletProvider).coins, after);
    });
  });

  group('activeEvent', () {
    test('weekends run Double Coins', () {
      final e = activeEvent(today: 100, weekday: DateTime.saturday);
      expect(e.coinMultiplier, 2);
      expect(e.hasBonus, isTrue);
    });
    test('weekdays show a non-bonus seasonal event', () {
      final e = activeEvent(today: 100, weekday: DateTime.wednesday);
      expect(e.coinMultiplier, 1);
      expect(e.hasBonus, isFalse);
    });
  });

  group('LocalLeaderboardService', () {
    test('ranks the player by score and marks the player row', () {
      final board = LocalLeaderboardService().board(
        playerScore: 999,
        playerName: 'Me',
      );
      expect(board.first.isPlayer, isTrue); // top score → rank 1
      expect(board.first.rank, 1);
      // Ranks are contiguous and sorted descending by score.
      for (var i = 1; i < board.length; i++) {
        expect(board[i].rank, i + 1);
        expect(board[i].score, lessThanOrEqualTo(board[i - 1].score));
      }
      expect(board.where((e) => e.isPlayer).length, 1);
    });
  });
}
