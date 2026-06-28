import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/app/theme/app_theme.dart';
import 'package:novaplay/core/widgets/widgets.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('semantic labels (screen-reader support)', () {
    testWidgets('CurrencyBadge reads amount + unit, not a bare number', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const CurrencyBadge(kind: CurrencyKind.coin, amount: 1240)),
      );
      expect(find.bySemanticsLabel('1240 coins'), findsOneWidget);
    });

    testWidgets('CurrencyBadge + affordance exposes a labelled button', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          CurrencyBadge(
            kind: CurrencyKind.stardust,
            amount: 5,
            onAdd: () => tapped = true,
          ),
        ),
      );
      final add = find.bySemanticsLabel('Add stardust');
      expect(add, findsOneWidget);
      await tester.tap(add);
      expect(tapped, isTrue);
    });

    testWidgets('LivesPill announces count, cap and full state', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const LivesPill(lives: 5, maxLives: 5)));
      expect(find.bySemanticsLabel('5 of 5 lives, full'), findsOneWidget);
    });

    testWidgets('LivesPill announces the regen countdown when not full', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LivesPill(
            lives: 2,
            maxLives: 5,
            countdown: Duration(minutes: 3, seconds: 5),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('2 of 5 lives, next in 3m 5s'),
        findsOneWidget,
      );
    });

    testWidgets('StarTriad and StarMeter read as "x of y stars"', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StarTriad(earned: 2)));
      expect(find.bySemanticsLabel('2 of 3 stars'), findsOneWidget);

      await tester.pumpWidget(_host(const StarMeter(earned: 40, total: 100)));
      expect(find.bySemanticsLabel('40 of 100 stars earned'), findsOneWidget);
    });

    testWidgets('LevelNode describes level, state and stars', (tester) async {
      await tester.pumpWidget(
        _host(
          const LevelNode(
            levelId: 7,
            state: LevelNodeState.cleared,
            sectorAccent: Color(0xFFFF8A5C),
            stars: 3,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Level 7, cleared, 3 of 3 stars'),
        findsOneWidget,
      );
    });

    testWidgets('a locked LevelNode is announced as locked and disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LevelNode(
            levelId: 8,
            state: LevelNodeState.locked,
            sectorAccent: Color(0xFFFF8A5C),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Level 8, locked'), findsOneWidget);
    });
  });

  group('tap targets', () {
    testWidgets('NovaIconButton meets the 48dp minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(NovaIconButton(icon: Icons.settings, onPressed: () {})),
      );
      final size = tester.getSize(find.byType(NovaIconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
