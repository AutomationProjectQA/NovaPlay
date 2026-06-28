import 'package:flutter/foundation.dart';

/// App-owned crash/error reporting (docs/ANALYTICS.md §2 Crashlytics). The
/// Crashlytics-backed implementation is swapped in once Firebase is connected
/// (SETUP.md); until then errors are logged so they're still visible.
abstract interface class CrashReporter {
  Future<void> init();

  /// Reports an error. [fatal] distinguishes uncaught crashes from caught
  /// non-fatals.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  });

  /// Attaches a custom key/value for crash context.
  Future<void> setCustomKey(String key, Object value);
}

/// Logs errors to the console — keeps reporting observable until Crashlytics is
/// wired. Web-safe (no native dependency).
class LoggingCrashReporter implements CrashReporter {
  @override
  Future<void> init() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    debugPrint('[crash${fatal ? ':fatal' : ''}] $error\n$stack');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}

/// No-op reporter (e.g. before consent / in tests).
class NoopCrashReporter implements CrashReporter {
  @override
  Future<void> init() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
