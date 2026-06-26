/// App-owned analytics interface. The Firebase-backed implementation is wired in
/// Sprint 17; see docs/ANALYTICS.md for the full event taxonomy.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserProperty(String name, String value);
}

/// No-op analytics used in dev and before consent is granted.
class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> setUserProperty(String name, String value) async {}
}
