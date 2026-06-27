import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/game/session/game_state.dart';

/// The minimal in-play HUD: pause · level · spark counter
/// (docs/UI_GUIDELINES.md §3.4). No currency chrome during play.
class GameplayHud extends StatelessWidget {
  const GameplayHud({
    required this.levelId,
    required this.state,
    required this.onPause,
    super.key,
  });

  final int levelId;
  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            NovaIconButton(
              icon: Icons.pause,
              tooltip: 'Pause',
              onPressed: onPause,
            ),
            const Spacer(),
            Text(
              'game_level'.tr(args: ['$levelId']),
              style: const TextStyle(
                color: AppColors.onHigh,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SparkCounter(
              remaining: state.sparksRemaining,
              total: state.sparksTotal,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
