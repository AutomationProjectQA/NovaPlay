import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';

/// An animated linear progress bar (docs/DESIGN_SYSTEM.md §4.9).
class NovaProgressBar extends StatelessWidget {
  const NovaProgressBar({
    required this.value,
    this.color = AppColors.nova500,
    this.height = 8,
    super.key,
  });

  /// Fill fraction, 0–1.
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(
        children: [
          Container(height: height, color: AppColors.surfaceOverlay),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: height,
                width: constraints.maxWidth * value.clamp(0.0, 1.0),
                color: color,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// XP bar with an inline "level N" caption (DS §4.9).
class XpBar extends StatelessWidget {
  const XpBar({
    required this.level,
    required this.progress,
    super.key,
  });

  final int level;

  /// Fraction toward the next level, 0–1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(color: AppColors.onHigh),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(color: AppColors.onMedium, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        NovaProgressBar(value: progress),
      ],
    );
  }
}
