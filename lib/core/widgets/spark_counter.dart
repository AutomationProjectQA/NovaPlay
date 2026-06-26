import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';

/// A single spark pip ✦ — filled when the spark is still available, hollow when
/// spent (docs/DESIGN_SYSTEM.md §4.6).
class SparkPip extends StatelessWidget {
  const SparkPip({required this.spent, this.size = 16, super.key});

  final bool spent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      spent ? Icons.star_border : Icons.star,
      size: size,
      color: spent ? AppColors.starDim : AppColors.nova500,
    );
  }
}

/// Shows remaining vs. used sparks for the current level. Renders a row of pips
/// up to [maxPips], then falls back to a compact "n/m" label.
class SparkCounter extends StatelessWidget {
  const SparkCounter({
    required this.remaining,
    required this.total,
    this.maxPips = 6,
    super.key,
  });

  final int remaining;
  final int total;
  final int maxPips;

  @override
  Widget build(BuildContext context) {
    if (total > maxPips) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SparkPip(spent: false),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$remaining/$total',
            style: const TextStyle(
              color: AppColors.onHigh,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs / 2),
            child: SparkPip(spent: i >= remaining),
          ),
      ],
    );
  }
}
