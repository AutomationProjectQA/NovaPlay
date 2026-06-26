import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/components/star_component.dart';

/// The NovaPlay Flame world (docs/ARCHITECTURE.md §8).
///
/// This is the Sprint 5 skeleton: it lays out a level's dim stars on the board
/// so the gameplay screen renders real content. The spark, physics, collisions,
/// input, and win/lose resolution are built out in Sprint 8.
class NovaGame extends FlameGame {
  NovaGame({required this.level});

  /// Logical coordinate space levels are authored in (see LEVEL_DESIGN.md).
  static const double logicalWidth = 100;
  static const double logicalHeight = 160;

  final LevelDefinition level;

  @override
  Color backgroundColor() => AppColors.space900;

  @override
  Future<void> onLoad() async {
    final scale = size.x / logicalWidth;
    for (final star in level.stars) {
      add(
        StarComponent(
          position: Vector2(star.x * scale, star.y * scale),
        ),
      );
    }
  }
}
