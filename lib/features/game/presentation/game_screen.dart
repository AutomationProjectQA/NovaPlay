import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/nova_game.dart';

/// Hosts the Flame [NovaGame] for a level plus the HUD overlay.
///
/// Sprint 5 mounts the engine with a demo level so the screen renders real
/// content; the level-asset loader, real HUD, and overlays come in Sprints 8–9.
class GameScreen extends StatelessWidget {
  const GameScreen({required this.levelId, super.key});

  final int levelId;

  LevelDefinition get _demoLevel => LevelDefinition(
    id: levelId,
    sector: 1,
    sparks: 5,
    parForThreeStars: 2,
    stars: const [
      LevelElement(type: 'star', x: 30, y: 50),
      LevelElement(type: 'star', x: 50, y: 90),
      LevelElement(type: 'star', x: 70, y: 60),
    ],
    elements: const [],
    introMechanic: 'aim',
  );

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text('game_level'.tr(args: ['$levelId'])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text('game_hint'.tr(), style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: GameWidget<NovaGame>.controlled(
                  gameFactory: () => NovaGame(level: _demoLevel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
