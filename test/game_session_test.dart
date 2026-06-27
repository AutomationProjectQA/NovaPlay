// Test ergonomics: chained controller calls and explicit defaults read clearer.
// ignore_for_file: cascade_invocations, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/game/session/game_result.dart';
import 'package:novaplay/game/session/game_session_controller.dart';
import 'package:novaplay/game/session/game_state.dart';

GameSessionController _controller({
  int sparks = 3,
  int stars = 2,
  int par = 2,
  void Function(GameResult)? onComplete,
}) {
  return GameSessionController(
    levelId: 1,
    initial: GameState.initial(
      sparks: sparks,
      starsTotal: stars,
      parForThreeStars: par,
    ),
    onComplete: onComplete,
  );
}

void main() {
  group('starsForResult', () {
    test('awards 3 stars at or under par', () {
      expect(
        starsForResult(sparksUsed: 2, parForThreeStars: 2, sparksTotal: 5),
        3,
      );
    });
    test('awards fewer stars as more sparks are used', () {
      expect(
        starsForResult(sparksUsed: 4, parForThreeStars: 2, sparksTotal: 5),
        2,
      );
      expect(
        starsForResult(sparksUsed: 5, parForThreeStars: 2, sparksTotal: 5),
        1,
      );
    });
  });

  group('GameSessionController', () {
    test('beginShot consumes a spark and enters shooting', () {
      final c = _controller();
      c.beginShot();
      expect(c.value.sparksRemaining, 2);
      expect(c.value.status, GameStatus.shooting);
    });

    test('lighting all stars wins and reports a result', () {
      GameResult? result;
      final c = _controller(onComplete: (r) => result = r);
      c
        ..beginShot()
        ..registerStarsLit(2);
      expect(c.value.status, GameStatus.won);
      expect(result?.won, isTrue);
      expect(result?.stars, 3); // 1 spark used, par 2
    });

    test('running out of sparks with stars dim is a loss', () {
      GameResult? result;
      final c = _controller(sparks: 1, onComplete: (r) => result = r);
      c
        ..beginShot()
        ..endShot();
      expect(c.value.status, GameStatus.lost);
      expect(result?.won, isFalse);
      expect(result?.stars, 0);
    });

    test('endShot returns to aiming while sparks remain', () {
      final c = _controller(sparks: 3)
        ..beginShot()
        ..endShot();
      expect(c.value.status, GameStatus.aiming);
      expect(c.value.sparksRemaining, 2);
    });

    test('pause and resume restore the prior status', () {
      final c = _controller()..beginShot();
      expect(c.value.status, GameStatus.shooting);
      c.pause();
      expect(c.value.status, GameStatus.paused);
      c.resume();
      expect(c.value.status, GameStatus.shooting);
    });

    test('no further changes after the level is over', () {
      final c = _controller(sparks: 1)
        ..beginShot()
        ..endShot();
      final lost = c.value;
      c.registerStarsLit(2);
      expect(c.value, lost);
    });
  });
}
