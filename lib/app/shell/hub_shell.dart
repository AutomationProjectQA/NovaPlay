import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/shell/hub_top_bar.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/core/widgets/space_background.dart';
import 'package:novaplay/features/rewards/presentation/daily_badge_provider.dart';

/// The persistent hub frame for the four root tabs (Home · Daily · Shop ·
/// Profile). Hosts the top HUD and the bottom navigation around the active
/// branch (docs/UI_GUIDELINES.md §1). Gameplay and settings live outside this
/// shell as full-screen leaves.
class HubShell extends ConsumerWidget {
  const HubShell({required this.navigationShell, super.key});

  /// The go_router stateful shell driving the indexed-stack branches.
  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHasBadge = ref.watch(hasUnclaimedDailyProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SpaceBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HubTopBar(),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        backgroundColor: AppColors.surfaceBase,
        indicatorColor: AppColors.nova500.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.public_outlined),
            selectedIcon: const Icon(Icons.public),
            label: 'nav_home'.tr(),
          ),
          NavigationDestination(
            icon: _maybeBadge(
              const Icon(Icons.calendar_today_outlined),
              show: dailyHasBadge,
            ),
            selectedIcon: _maybeBadge(
              const Icon(Icons.calendar_today),
              show: dailyHasBadge,
            ),
            label: 'nav_daily'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: 'nav_shop'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'nav_profile'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _maybeBadge(Widget child, {required bool show}) {
    if (!show) return child;
    return Badge(backgroundColor: AppColors.nova500, child: child);
  }
}
