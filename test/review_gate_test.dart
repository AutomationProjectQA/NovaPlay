import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/review_gate.dart';

void main() {
  group('ReviewGate.shouldRequestReview', () {
    test('does not ask before the player has cleared enough levels', () {
      expect(
        ReviewGate.shouldRequestReview(
          levelsCleared: ReviewGate.minLevelsCleared - 1,
          lastPromptLevel: 0,
          alreadyReviewed: false,
        ),
        isFalse,
      );
    });

    test('asks once the minimum is reached and never prompted', () {
      expect(
        ReviewGate.shouldRequestReview(
          levelsCleared: ReviewGate.minLevelsCleared,
          lastPromptLevel: 0,
          alreadyReviewed: false,
        ),
        isTrue,
      );
    });

    test('never asks a player who already reviewed', () {
      expect(
        ReviewGate.shouldRequestReview(
          levelsCleared: 50,
          lastPromptLevel: 0,
          alreadyReviewed: true,
        ),
        isFalse,
      );
    });

    test('stays quiet during the cooldown after a prompt', () {
      expect(
        ReviewGate.shouldRequestReview(
          levelsCleared: 10,
          lastPromptLevel: 5, // only 5 levels ago, cooldown is 20
          alreadyReviewed: false,
        ),
        isFalse,
      );
    });

    test('may ask again once the cooldown has elapsed', () {
      expect(
        ReviewGate.shouldRequestReview(
          levelsCleared: 5 + ReviewGate.cooldownLevels,
          lastPromptLevel: 5,
          alreadyReviewed: false,
        ),
        isTrue,
      );
    });
  });
}
