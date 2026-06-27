/// Centralized route paths and names for GoRouter (docs/ARCHITECTURE.md §7,
/// docs/NAVIGATION.md). Hub tabs live inside the stateful shell; the rest are
/// full-screen leaves pushed over it.
abstract final class Routes {
  // Boot.
  static const String splash = '/';

  // Hub tabs (inside the bottom-nav shell).
  static const String home = '/home';
  static const String daily = '/daily';
  static const String shop = '/shop';
  static const String profile = '/profile';

  // Full-screen leaves (over the shell, no bottom nav).
  static const String settings = '/settings';
  static const String leaderboard = '/leaderboard';
  static const String levelSelect = '/levels/:sectorId';
  static const String game = '/game/:levelId';

  /// Dev-only design-system showcase (Sprint 6).
  static const String gallery = '/gallery';

  /// Builds the level-select path for a given sector id.
  static String levelSelectPath(int sectorId) => '/levels/$sectorId';

  /// Builds the gameplay path for a given level id.
  static String gamePath(int levelId) => '/game/$levelId';
}
