import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/update_gate.dart';

void main() {
  group('evaluateUpdate', () {
    test('below the minimum supported build is a hard block', () {
      expect(
        evaluateUpdate(currentBuild: 4, minSupportedBuild: 5, latestBuild: 9),
        UpdateStatus.updateRequired,
      );
    });

    test('at or above minimum but behind latest is a soft nudge', () {
      expect(
        evaluateUpdate(currentBuild: 5, minSupportedBuild: 5, latestBuild: 9),
        UpdateStatus.updateAvailable,
      );
    });

    test('on the latest build is up to date', () {
      expect(
        evaluateUpdate(currentBuild: 9, minSupportedBuild: 5, latestBuild: 9),
        UpdateStatus.upToDate,
      );
    });

    test('an unset latestBuild (0) disables the soft nudge', () {
      expect(
        evaluateUpdate(currentBuild: 5, minSupportedBuild: 5),
        UpdateStatus.upToDate,
      );
    });

    test('required wins over available', () {
      // current below min AND below latest → still required, not available.
      expect(
        evaluateUpdate(currentBuild: 1, minSupportedBuild: 3, latestBuild: 9),
        UpdateStatus.updateRequired,
      );
    });
  });
}
