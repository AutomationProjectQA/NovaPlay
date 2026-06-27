/// App-owned notifications interface for local reminders + remote push
/// (docs/CONCEPT.md §11, ARCHITECTURE.md §6). The shipped implementation is a
/// no-op; the real one (flutter_local_notifications + FCM) is wired once the
/// platform setup and Firebase project are connected (see SETUP.md).
abstract interface class NotificationService {
  /// Requests OS notification permission (no-op until implemented).
  Future<void> init();

  /// Schedules a "lives refilled" reminder [after] the given delay.
  Future<void> scheduleLivesFull(Duration after);

  /// Schedules the next "daily reward ready" reminder.
  Future<void> scheduleDailyReady();

  /// Cancels all pending reminders (e.g. when the player returns).
  Future<void> cancelAll();
}

/// No-op notifications — keeps call sites clean until real notifications land.
class NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleLivesFull(Duration after) async {}

  @override
  Future<void> scheduleDailyReady() async {}

  @override
  Future<void> cancelAll() async {}
}
