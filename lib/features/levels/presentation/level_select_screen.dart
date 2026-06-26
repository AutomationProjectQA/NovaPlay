import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/levels/domain/sector.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';

/// The level grid for a single sector (docs/UI_GUIDELINES.md §3.3). A full-screen
/// leaf pushed over the hub shell. Level node states (locked/next/cleared) are
/// stubbed for Sprint 7; real per-level progress lands in Sprint 10.
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
    final continueLevel = ref.watch(continueLevelProvider);

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
          final state = _stateFor(levelId, continueLevel);
          return LevelNode(
            levelId: levelId,
            state: state,
            sectorAccent: sector.accent,
            stars: state == LevelNodeState.cleared ? _stubStars(levelId) : 0,
            isFinale: levelId == sector.lastLevel,
            onTap: state == LevelNodeState.locked
                ? null
                : () => context.push(Routes.gamePath(levelId)),
          );
        },
      ),
    );
  }

  LevelNodeState _stateFor(int levelId, int continueLevel) {
    if (levelId < continueLevel) return LevelNodeState.cleared;
    if (levelId == continueLevel) return LevelNodeState.next;
    return LevelNodeState.locked;
  }

  int _stubStars(int levelId) => (levelId % 3) + 1;
}

/// Convenience for building a labelled sector chip elsewhere if needed.
extension SectorLabel on Sector {
  String get rangeLabel => '$firstLevel–$lastLevel';
}
