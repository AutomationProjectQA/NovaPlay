import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/experiments/experiment.dart';

const _exp = Experiment(
  key: 'demo',
  control: 'a',
  variants: [Variant('a'), Variant('b')],
);

void main() {
  group('assignVariant', () {
    test('is deterministic for the same unit', () {
      final first = assignVariant(_exp, 'install-123');
      final second = assignVariant(_exp, 'install-123');
      expect(first, second);
    });

    test('always returns a defined variant', () {
      for (var i = 0; i < 500; i++) {
        expect(['a', 'b'], contains(assignVariant(_exp, 'unit-$i')));
      }
    });

    test('roughly honors weights across many units', () {
      const weighted = Experiment(
        key: 'weighted',
        control: 'a',
        variants: [Variant('a'), Variant('b', 3)], // expect ~25% / ~75%
      );
      var b = 0;
      const n = 4000;
      for (var i = 0; i < n; i++) {
        if (assignVariant(weighted, 'u$i') == 'b') b++;
      }
      final share = b / n;
      expect(share, greaterThan(0.65));
      expect(share, lessThan(0.85));
    });

    test('empty/zero-weight variants fall back to control', () {
      const empty = Experiment(key: 'e', control: 'ctrl', variants: []);
      expect(assignVariant(empty, 'x'), 'ctrl');
    });
  });

  group('resolveVariant override', () {
    test('auto / empty use deterministic assignment', () {
      expect(resolveVariant(_exp, 'u', 'auto'), assignVariant(_exp, 'u'));
      expect(resolveVariant(_exp, 'u', ''), assignVariant(_exp, 'u'));
    });

    test('control pins the control arm', () {
      expect(resolveVariant(_exp, 'u', 'control'), 'a');
    });

    test('a known variant id forces that arm', () {
      expect(resolveVariant(_exp, 'u', 'b'), 'b');
    });

    test('an unknown override falls back to assignment', () {
      expect(resolveVariant(_exp, 'u', 'zzz'), assignVariant(_exp, 'u'));
    });
  });
}
