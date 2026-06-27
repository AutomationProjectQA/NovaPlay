import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/game/session/game_state.dart';

/// A dimming scrim + centered card with a scale+fade entrance
/// (docs/DESIGN_SYSTEM.md §5: 240 ms). Under reduced motion it fades only.
class _OverlayShell extends StatelessWidget {
  const _OverlayShell({required this.reducedMotion, required this.child});

  final bool reducedMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return ColoredBox(
          color: AppColors.space900.withValues(alpha: 0.72 * t),
          child: Center(
            child: Opacity(
              opacity: t,
              child: Transform.scale(
                scale: reducedMotion ? 1.0 : (0.96 + 0.04 * t),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: NovaCard(child: child),
      ),
    );
  }
}

/// A row of up to three stars that pop in sequentially (docs/DESIGN_SYSTEM.md
/// §5: staggered `easeOutBack`). Reduced motion shows them immediately.
class _StarPopRow extends StatefulWidget {
  const _StarPopRow({required this.earned, required this.reducedMotion});

  final int earned;
  final bool reducedMotion;

  @override
  State<_StarPopRow> createState() => _StarPopRowState();
}

class _StarPopRowState extends State<_StarPopRow> {
  late final List<bool> _shown = List.filled(3, widget.reducedMotion);

  @override
  void initState() {
    super.initState();
    if (widget.reducedMotion) return;
    for (var i = 0; i < 3; i++) {
      unawaited(
        Future.delayed(Duration(milliseconds: 120 * (i + 1)), () {
          if (mounted) setState(() => _shown[i] = true);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          AnimatedScale(
            scale: _shown[i] ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Icon(
              i < widget.earned ? Icons.star : Icons.star_border,
              size: 36,
              color: i < widget.earned ? AppColors.starLit : AppColors.starDim,
            ),
          ),
      ],
    );
  }
}

/// Shown when the level is cleared (docs/UI_GUIDELINES.md §3.6).
class WinOverlay extends StatelessWidget {
  const WinOverlay({
    required this.stars,
    required this.coins,
    required this.reducedMotion,
    required this.onNext,
    required this.onReplay,
    required this.onMap,
    super.key,
  });

  final int stars;
  final int coins;
  final bool reducedMotion;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      reducedMotion: reducedMotion,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Constellation lit!', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          _StarPopRow(earned: stars, reducedMotion: reducedMotion),
          const SizedBox(height: AppSpacing.md),
          Text('+$coins coins', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          NovaButton(
            label: 'Next',
            icon: Icons.arrow_forward,
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: NovaButton(
                  label: 'Replay',
                  variant: NovaButtonVariant.ghost,
                  onPressed: onReplay,
                ),
              ),
              Expanded(
                child: NovaButton(
                  label: 'Map',
                  variant: NovaButtonVariant.ghost,
                  onPressed: onMap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when the player runs out of sparks (docs/UI_GUIDELINES.md §3.7).
/// Gentle — never a harsh "FAIL".
class LoseOverlay extends StatelessWidget {
  const LoseOverlay({
    required this.starsRemaining,
    required this.reducedMotion,
    required this.onRetry,
    required this.onMap,
    super.key,
  });

  final int starsRemaining;
  final bool reducedMotion;
  final VoidCallback onRetry;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      reducedMotion: reducedMotion,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('So close.', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$starsRemaining star${starsRemaining == 1 ? '' : 's'} still dim',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          NovaButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
          const SizedBox(height: AppSpacing.xs),
          NovaButton(
            label: 'Map',
            variant: NovaButtonVariant.ghost,
            onPressed: onMap,
          ),
        ],
      ),
    );
  }
}

/// The pause menu (docs/UI_GUIDELINES.md §3.5).
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.reducedMotion,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
    super.key,
  });

  final bool reducedMotion;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return _OverlayShell(
      reducedMotion: reducedMotion,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Paused', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          NovaButton(
            label: 'Resume',
            icon: Icons.play_arrow,
            onPressed: onResume,
          ),
          const SizedBox(height: AppSpacing.xs),
          NovaButton(
            label: 'Restart',
            variant: NovaButtonVariant.secondary,
            onPressed: onRestart,
          ),
          const SizedBox(height: AppSpacing.xs),
          NovaButton(
            label: 'Quit to map',
            variant: NovaButtonVariant.ghost,
            onPressed: onQuit,
          ),
        ],
      ),
    );
  }
}

/// Picks the overlay (if any) for the current [status].
Widget? overlayForStatus({
  required GameStatus status,
  required int stars,
  required int coins,
  required int starsRemaining,
  required bool reducedMotion,
  required VoidCallback onNext,
  required VoidCallback onReplay,
  required VoidCallback onRetry,
  required VoidCallback onMap,
  required VoidCallback onResume,
  required VoidCallback onRestart,
  required VoidCallback onQuit,
}) {
  switch (status) {
    case GameStatus.won:
      return WinOverlay(
        stars: stars,
        coins: coins,
        reducedMotion: reducedMotion,
        onNext: onNext,
        onReplay: onReplay,
        onMap: onMap,
      );
    case GameStatus.lost:
      return LoseOverlay(
        starsRemaining: starsRemaining,
        reducedMotion: reducedMotion,
        onRetry: onRetry,
        onMap: onMap,
      );
    case GameStatus.paused:
      return PauseOverlay(
        reducedMotion: reducedMotion,
        onResume: onResume,
        onRestart: onRestart,
        onQuit: onQuit,
      );
    case GameStatus.aiming:
    case GameStatus.shooting:
      return null;
  }
}
