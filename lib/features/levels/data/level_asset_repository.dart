import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/physics/physics_constants.dart';

/// Loads handcrafted level JSON from `assets/levels/` (docs/ARCHITECTURE.md §9).
///
/// Until all 100 levels are authored (Sprint 10), missing levels fall back to a
/// deterministic generated layout so every level is playable and testable.
class LevelAssetRepository {
  const LevelAssetRepository();

  Future<LevelDefinition> load(int levelId) async {
    final sector = ((levelId - 1) ~/ 20) + 1;
    final path =
        'assets/levels/sector_${_pad(sector, 2)}/level_${_pad(levelId, 3)}.json';
    try {
      final raw = await rootBundle.loadString(path);
      return LevelDefinition.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } on Exception {
      return _generated(levelId, sector);
    }
  }

  String _pad(int value, int width) => value.toString().padLeft(width, '0');

  /// A deterministic placeholder layout seeded by [levelId]. Star count and
  /// difficulty scale gently with the level number.
  LevelDefinition _generated(int levelId, int sector) {
    var seed = levelId * 2654435761 & 0x7fffffff;
    double next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    final starCount = 3 + (levelId % 3);
    final stars = <LevelElement>[
      for (var i = 0; i < starCount; i++)
        LevelElement(
          type: 'star',
          x: 12 + next() * (PhysicsConstants.boardWidth - 24),
          y: 18 + next() * (PhysicsConstants.boardHeight * 0.6),
        ),
    ];

    final elements = <LevelElement>[
      LevelElement(
        type: 'wall',
        x: 20 + next() * 60,
        y: 70 + next() * 30,
        params: const {'w': 26, 'h': 3},
      ),
      if (sector >= 2)
        LevelElement(
          type: 'bumper',
          x: 25 + next() * 50,
          y: 50 + next() * 20,
          params: const {'w': 16},
        ),
    ];

    return LevelDefinition(
      id: levelId,
      sector: sector,
      sparks: starCount + 2,
      parForThreeStars: starCount,
      stars: stars,
      elements: elements,
      introMechanic: levelId == 1 ? 'aim' : null,
    );
  }
}
