import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/analytics_observer.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/shell/hub_shell.dart';
import 'package:novaplay/core/widgets/error_screen.dart';
import 'package:novaplay/features/daily/presentation/daily_screen.dart';
import 'package:novaplay/features/gallery/presentation/gallery_screen.dart';
import 'package:novaplay/features/game/presentation/game_screen.dart';
import 'package:novaplay/features/home/presentation/home_screen.dart';
import 'package:novaplay/features/levels/presentation/level_select_screen.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/live/presentation/leaderboard_screen.dart';
import 'package:novaplay/features/onboarding/presentation/splash_screen.dart';
import 'package:novaplay/features/profile/presentation/profile_screen.dart';
import 'package:novaplay/features/settings/presentation/settings_screen.dart';
import 'package:novaplay/features/shop/presentation/shop_screen.dart';

/// Builds the app's GoRouter (docs/NAVIGATION.md). A stateful shell route hosts
/// the four bottom-nav tabs; settings/level-select/gameplay are full-screen
/// leaves pushed over the shell. `ref` is used by route guards.
abstract final class AppRouter {
  static GoRouter build(WidgetRef ref) {
    return GoRouter(
      initialLocation: Routes.splash,
      observers: [AnalyticsNavObserver()],
      errorBuilder: (context, state) =>
          ErrorScreen(message: state.error?.toString()),
      routes: [
        GoRoute(
          path: Routes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          pageBuilder: (context, state) =>
              _fadePage(state, const SettingsScreen()),
        ),
        GoRoute(
          path: Routes.levelSelect,
          name: 'levelSelect',
          pageBuilder: (context, state) {
            final sectorId =
                int.tryParse(state.pathParameters['sectorId'] ?? '') ?? 1;
            return _fadePage(state, LevelSelectScreen(sectorId: sectorId));
          },
        ),
        GoRoute(
          path: Routes.game,
          name: 'game',
          redirect: (context, state) {
            final levelId =
                int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
            // Locked-level guard: deep links to not-yet-unlocked levels bounce
            // back to the map.
            if (levelId > ref.read(continueLevelProvider)) return Routes.home;
            return null;
          },
          pageBuilder: (context, state) {
            final levelId =
                int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
            return _fadePage(state, GameScreen(levelId: levelId));
          },
        ),
        GoRoute(
          path: Routes.leaderboard,
          name: 'leaderboard',
          pageBuilder: (context, state) =>
              _fadePage(state, const LeaderboardScreen()),
        ),
        GoRoute(
          path: Routes.gallery,
          name: 'gallery',
          pageBuilder: (context, state) =>
              _fadePage(state, const GalleryScreen()),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HubShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.home,
                  name: 'home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.daily,
                  name: 'daily',
                  builder: (context, state) => const DailyScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.shop,
                  name: 'shop',
                  builder: (context, state) => const ShopScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.profile,
                  name: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// A gentle fade transition for full-screen leaf routes (240 ms in, per
  /// docs/DESIGN_SYSTEM.md §5). Sets the page name for the analytics observer.
  static CustomTransitionPage<void> _fadePage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}
