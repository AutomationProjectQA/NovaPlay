import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/data/level_asset_repository.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/features/levels/domain/sector.dart';

/// The five sectors with the player's progress. Stubbed for Sprint 7 (the first
/// two sectors partially complete); real progress is loaded from save data and
/// the level manifest in Sprint 10.
final sectorsProvider = Provider<List<Sector>>((ref) {
  return const [
    Sector(
      id: 1,
      name: 'Embers',
      accent: AppColors.sectorEmbers,
      firstLevel: 1,
      lastLevel: 20,
      starsEarned: 52,
      unlocked: true,
    ),
    Sector(
      id: 2,
      name: 'Nebula',
      accent: AppColors.sectorNebula,
      firstLevel: 21,
      lastLevel: 40,
      starsEarned: 14,
      unlocked: true,
    ),
    Sector(
      id: 3,
      name: 'Void',
      accent: AppColors.sectorVoid,
      firstLevel: 41,
      lastLevel: 60,
      starsEarned: 0,
      unlocked: false,
    ),
    Sector(
      id: 4,
      name: 'Pulsar',
      accent: AppColors.sectorPulsar,
      firstLevel: 61,
      lastLevel: 80,
      starsEarned: 0,
      unlocked: false,
    ),
    Sector(
      id: 5,
      name: 'Singularity',
      accent: AppColors.sectorSingularity,
      firstLevel: 81,
      lastLevel: 100,
      starsEarned: 0,
      unlocked: false,
    ),
  ];
});

/// The level the "Continue" affordance should launch. Stubbed for Sprint 7.
final continueLevelProvider = Provider<int>((ref) => 5);

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
