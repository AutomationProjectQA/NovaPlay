import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/core/widgets/error_screen.dart';
import 'package:novaplay/features/gallery/presentation/gallery_screen.dart';
import 'package:novaplay/features/game/presentation/game_screen.dart';
import 'package:novaplay/features/home/presentation/home_screen.dart';
import 'package:novaplay/features/levels/presentation/level_select_screen.dart';
import 'package:novaplay/features/onboarding/presentation/splash_screen.dart';
import 'package:novaplay/features/profile/presentation/profile_screen.dart';
import 'package:novaplay/features/settings/presentation/settings_screen.dart';

/// The app's GoRouter configuration (docs/ARCHITECTURE.md §7).
abstract final class AppRouter {
  static GoRouter build() {
    return GoRouter(
      initialLocation: Routes.splash,
      errorBuilder: (context, state) =>
          ErrorScreen(message: state.error?.toString()),
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.levelSelect,
          builder: (context, state) => const LevelSelectScreen(),
        ),
        GoRoute(
          path: Routes.game,
          builder: (context, state) {
            final levelId =
                int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1;
            return GameScreen(levelId: levelId);
          },
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: Routes.gallery,
          builder: (context, state) => const GalleryScreen(),
        ),
      ],
    );
  }
}
