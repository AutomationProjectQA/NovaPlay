import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/analytics_service.dart';

/// Logs a `screen_view` analytics event on every route push/pop so funnels in
/// docs/ANALYTICS.md are populated automatically. Reads the screen name from the
/// route's path (docs/ARCHITECTURE.md §12).
class AnalyticsNavObserver extends NavigatorObserver {
  AnalyticsNavObserver() : _analytics = getIt<AnalyticsService>();

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log(previousRoute);
  }

  void _log(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(
      _analytics.logEvent('screen_view', parameters: {'screen_name': name}),
    );
  }
}
