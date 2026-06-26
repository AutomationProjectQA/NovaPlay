/// Centralized route paths and names for GoRouter (docs/ARCHITECTURE.md §7).
abstract final class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String levelSelect = '/levels';
  static const String game = '/game/:levelId';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Builds the concrete game path for a given level id.
  static String gamePath(int levelId) => '/game/$levelId';
}
