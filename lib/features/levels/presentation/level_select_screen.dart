import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';
import 'package:novaplay/features/levels/domain/sector.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// The level grid for a single sector (docs/UI_GUIDELINES.md §3.3). A full-screen
/// leaf pushed over the hub shell. Node states and stars come from saved
/// progress.
class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({required this.sectorId, super.key});

  final int sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectors = ref.watch(sectorsProvider);
    final sector = sectors.firstWhere(
      (s) => s.id == sectorId,
      orElse: () => sectors.first,
    );
    final highestUnlocked = ref.watch(highestUnlockedLevelProvider);
    final progress = ref.watch(progressProvider);

    return NovaScaffold(
      appBar: AppBar(
        title: Text(sector.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: StarMeter(
                earned: sector.starsEarned,
                total: sector.starsTotal,
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sector.levelCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          final levelId = sector.firstLevel + index;
          final stars = progress[levelId] ?? 0;
          final state = _stateFor(levelId, highestUnlocked, stars);
          return LevelNode(
            levelId: levelId,
            state: state,
            sectorAccent: sector.accent,
            stars: stars,
            isFinale: levelId == sector.lastLevel,
            onTap: state == LevelNodeState.locked
                ? null
                : () => launchLevelOrRefill(
                    context,
                    ref,
                    Routes.gamePath(levelId),
                  ),
          );
        },
      ),
    );
  }

  LevelNodeState _stateFor(int levelId, int highestUnlocked, int stars) {
    if (stars > 0) return LevelNodeState.cleared;
    if (levelId == highestUnlocked) return LevelNodeState.next;
    if (levelId < highestUnlocked) return LevelNodeState.cleared;
    return LevelNodeState.locked;
  }
}

/// Convenience for building a labelled sector chip elsewhere if needed.
extension SectorLabel on Sector {
  String get rangeLabel => '$firstLevel–$lastLevel';
}
