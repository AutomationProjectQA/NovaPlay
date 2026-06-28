import 'package:flutter/foundation.dart';

/// App-owned analytics interface (docs/ANALYTICS.md). The Firebase Analytics
/// (GA4) implementation is swapped in once the backend is connected (SETUP.md).
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserProperty(String name, String value);
}

/// No-op analytics (production until Firebase is wired; pre-consent).
class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> setUserProperty(String name, String value) async {}
}

/// Logs every event to the debug console — observable analytics for dev/QA.
class LoggingAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    debugPrint('[analytics] $name ${parameters ?? {}}');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    debugPrint('[analytics] user_property $name=$value');
  }
}

/// Records events in memory for tests/assertions.
class RecordingAnalyticsService implements AnalyticsService {
  final List<({String name, Map<String, Object> params})> events = [];
  final Map<String, String> userProperties = {};

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, params: parameters ?? const {}));
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    userProperties[name] = value;
  }
}
