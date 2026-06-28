import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';

/// Formats a currency amount compactly (1200 -> "1.2k", 1500000 -> "1.5M").
String formatCount(int value) {
  if (value < 1000) return '$value';
  if (value < 1000000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k >= 100 ? 0 : 1)}k';
  }
  final m = value / 1000000;
  return '${m.toStringAsFixed(1)}M';
}

/// The two spendable currencies (docs/CONCEPT.md §7).
enum CurrencyKind { coin, stardust }

/// A compact top-HUD currency pill with an optional `+` affordance (DS §4.7).
class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({
    required this.kind,
    required this.amount,
    this.onAdd,
    super.key,
  });

  final CurrencyKind kind;
  final int amount;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final (icon, color, unit) = switch (kind) {
      CurrencyKind.coin => (Icons.monetization_on, AppColors.coin, 'coins'),
      CurrencyKind.stardust => (
        Icons.auto_awesome,
        AppColors.stardust,
        'stardust',
      ),
    };

    return Material(
      color: AppColors.surfaceOverlay,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reads as one label (e.g. "1,240 coins"); the icon is decorative.
            Semantics(
              label: '$amount $unit',
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    formatCount(amount),
                    style: const TextStyle(
                      color: AppColors.onHigh,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              Semantics(
                button: true,
                label: 'Add $unit',
                child: InkResponse(
                  onTap: onAdd,
                  radius: 22,
                  child: const Icon(
                    Icons.add_circle,
                    size: 18,
                    color: AppColors.nova500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lives/energy pill with a regen countdown when not full (DS §4.6).
class LivesPill extends StatelessWidget {
  const LivesPill({
    required this.lives,
    required this.maxLives,
    this.countdown,
    this.onTap,
    super.key,
  });

  final int lives;
  final int maxLives;

  /// Time until the next life regenerates; hidden when full.
  final Duration? countdown;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isFull = lives >= maxLives;
    final label = isFull
        ? '$lives of $maxLives lives, full'
        : countdown != null
        ? '$lives of $maxLives lives, next in ${_spoken(countdown!)}'
        : '$lives of $maxLives lives';
    return Material(
      color: AppColors.surfaceOverlay,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Semantics(
        label: label,
        button: onTap != null,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: isFull ? AppColors.error : AppColors.warn,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text('$lives', style: const TextStyle(color: AppColors.onHigh)),
                if (!isFull && countdown != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _format(countdown!),
                    style: const TextStyle(
                      color: AppColors.onMedium,
                      fontSize: 12,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Screen-reader-friendly duration, e.g. "3 minutes 5 seconds".
  String _spoken(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
