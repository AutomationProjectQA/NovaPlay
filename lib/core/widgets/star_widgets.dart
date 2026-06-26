import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';

/// The 0–3 star rating arc shown under a level node / result (DS §4.8).
class StarTriad extends StatelessWidget {
  const StarTriad({required this.earned, this.size = 18, super.key});

  /// Number of earned stars, clamped to 0–3.
  final int earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = earned.clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < filled ? Icons.star : Icons.star_border,
            size: size,
            color: i < filled ? AppColors.starLit : AppColors.starDim,
          ),
      ],
    );
  }
}

/// "⭐ earned/total" progress label for the map & profile (DS §4.6 Star meter).
class StarMeter extends StatelessWidget {
  const StarMeter({required this.earned, required this.total, super.key});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppColors.starLit, size: 18),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$earned/$total',
          style: const TextStyle(
            color: AppColors.onHigh,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
