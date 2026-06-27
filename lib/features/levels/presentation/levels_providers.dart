import 'dart:ui' show Color;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/data/level_asset_repository.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/features/levels/domain/sector.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';

/// Static sector definitions (id, name, accent, level range).
const List<({int id, String name, Color accent, int first, int last})>
_sectorDefs = [
  (id: 1, name: 'Embers', accent: AppColors.sectorEmbers, first: 1, last: 20),
  (id: 2, name: 'Nebula', accent: AppColors.sectorNebula, first: 21, last: 40),
  (id: 3, name: 'Void', accent: AppColors.sectorVoid, first: 41, last: 60),
  (id: 4, name: 'Pulsar', accent: AppColors.sectorPulsar, first: 61, last: 80),
  (
    id: 5,
    name: 'Singularity',
    accent: AppColors.sectorSingularity,
    first: 81,
    last: 100,
  ),
];

/// The five sectors with the player's live progress (stars earned + unlock
/// state derived from saved progress; docs/CONCEPT.md §6).
final sectorsProvider = Provider<List<Sector>>((ref) {
  final progress = ref.watch(progressProvider);
  final highest = ref.watch(highestUnlockedLevelProvider);
  return [
    for (final def in _sectorDefs)
      Sector(
        id: def.id,
        name: def.name,
        accent: def.accent,
        firstLevel: def.first,
        lastLevel: def.last,
        starsEarned: _starsInRange(progress, def.first, def.last),
        unlocked: def.first <= highest,
      ),
  ];
});

int _starsInRange(Map<int, int> progress, int first, int last) {
  var total = 0;
  for (var level = first; level <= last; level++) {
    total += progress[level] ?? 0;
  }
  return total;
}

/// The level the "Continue" affordance should launch (next unlocked level).
final continueLevelProvider = Provider<int>((ref) {
  return ref.watch(highestUnlockedLevelProvider);
});

/// Loads level definitions from assets (with a generated fallback).
final levelRepositoryProvider = Provider<LevelAssetRepository>((ref) {
  return const LevelAssetRepository();
});

/// Loads a single [LevelDefinition] by id.
final levelProvider = FutureProvider.family<LevelDefinition, int>((
  ref,
  levelId,
) {
  return ref.read(levelRepositoryProvider).load(levelId);
});
