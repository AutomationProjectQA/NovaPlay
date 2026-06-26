import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/app/theme/app_theme.dart';
import 'package:novaplay/core/widgets/widgets.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  group('formatCount', () {
    test('formats thousands and millions', () {
      expect(formatCount(999), '999');
      expect(formatCount(1240), '1.2k');
      expect(formatCount(150000), '150k');
      expect(formatCount(1500000), '1.5M');
    });
  });

  testWidgets('NovaButton fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(NovaButton(label: 'Go', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Go'));
    expect(taps, 1);
  });

  testWidgets('NovaButton is inert while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(NovaButton(label: 'Go', isLoading: true, onPressed: () => taps++)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(taps, 0);
  });

  testWidgets('SparkCounter renders a pip per spark', (tester) async {
    await tester.pumpWidget(_host(const SparkCounter(remaining: 2, total: 4)));
    expect(find.byType(SparkPip), findsNWidgets(4));
  });

  testWidgets('LevelNode shows a lock when locked', (tester) async {
    await tester.pumpWidget(
      _host(
        const LevelNode(
          levelId: 7,
          state: LevelNodeState.locked,
          sectorAccent: Color(0xFFFF8A5C),
        ),
      ),
    );
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('7'), findsNothing);
  });
}
