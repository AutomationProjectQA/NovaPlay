import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/analytics_events.dart';
import 'package:novaplay/core/services/analytics_service.dart';

void main() {
  group('NovaAnalytics typed events', () {
    late RecordingAnalyticsService analytics;

    setUp(() => analytics = RecordingAnalyticsService());

    test('level_complete emits the right name and params', () {
      analytics.logLevelComplete(
        levelId: 7,
        sectorId: 1,
        stars: 3,
        sparksUsed: 2,
      );
      final event = analytics.events.single;
      expect(event.name, AnalyticsEvent.levelComplete);
      expect(event.params[AnalyticsParam.levelId], 7);
      expect(event.params[AnalyticsParam.stars], 3);
      expect(event.params[AnalyticsParam.sparksUsed], 2);
    });

    test('currency_earned carries currency/amount/source', () {
      analytics.logCurrencyEarned(currency: 'coins', amount: 40, source: 'win');
      final event = analytics.events.single;
      expect(event.name, AnalyticsEvent.currencyEarned);
      expect(event.params[AnalyticsParam.amount], 40);
      expect(event.params[AnalyticsParam.source], 'win');
    });

    test('settings_changed records setting + value', () {
      analytics.logSettingsChanged(setting: 'haptics', value: false);
      expect(analytics.events.single.name, AnalyticsEvent.settingsChanged);
      expect(
        analytics.events.single.params[AnalyticsParam.value],
        isFalse,
      );
    });

    test('all event names obey GA4 limits (snake_case, <= 40 chars)', () {
      const names = [
        AnalyticsEvent.appOpen,
        AnalyticsEvent.levelStart,
        AnalyticsEvent.levelComplete,
        AnalyticsEvent.levelFail,
        AnalyticsEvent.dailyRewardClaimed,
        AnalyticsEvent.adRewarded,
        AnalyticsEvent.errorNonfatal,
      ];
      for (final name in names) {
        expect(name.length, lessThanOrEqualTo(40));
        expect(name, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      }
    });
  });
}
