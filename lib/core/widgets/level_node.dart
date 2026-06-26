import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_glow.dart';
import 'package:novaplay/core/widgets/star_widgets.dart';

/// The visual/interaction state of a [LevelNode] (docs/DESIGN_SYSTEM.md §4.8).
enum LevelNodeState { locked, next, cleared }

/// A single level on the sector map: a circular node with a center label, a
/// sector-accent ring, and a 0–3 star arc below.
class LevelNode extends StatelessWidget {
  const LevelNode({
    required this.levelId,
    required this.state,
    required this.sectorAccent,
    this.stars = 0,
    this.isFinale = false,
    this.onTap,
    super.key,
  });

  final int levelId;
  final LevelNodeState state;
  final Color sectorAccent;
  final int stars;

  /// Supernova finale nodes render larger with a stronger glow.
  final bool isFinale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = isFinale ? 72.0 : 56.0;
    final isLocked = state == LevelNodeState.locked;

    final fill = switch (state) {
      LevelNodeState.locked => AppColors.surfaceBase,
      LevelNodeState.next => AppColors.surfaceRaised,
      LevelNodeState.cleared => AppColors.surfaceRaised,
    };
    final ringColor = isLocked ? AppColors.onDisabled : sectorAccent;
    final glow = state == LevelNodeState.next || isFinale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: Border.all(color: ringColor, width: isFinale ? 3 : 2),
              boxShadow: glow ? NovaGlow.sector(sectorAccent) : null,
            ),
            child: Center(child: _label(isLocked)),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (state == LevelNodeState.cleared)
          StarTriad(earned: stars, size: 12)
        else
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _label(bool isLocked) {
    if (isLocked) {
      return const Icon(Icons.lock, size: 20, color: AppColors.onDisabled);
    }
    if (isFinale) {
      return const Icon(Icons.auto_awesome, size: 26, color: AppColors.nova500);
    }
    return Text(
      '$levelId',
      style: const TextStyle(
        color: AppColors.onHigh,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}
