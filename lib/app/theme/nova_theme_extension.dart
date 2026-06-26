import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Custom theme tokens that have no Material equivalent (sector accents,
/// star/currency colors, the space gradient). Access via
/// `Theme.of(context).extension<NovaTheme>()!`.
@immutable
class NovaTheme extends ThemeExtension<NovaTheme> {
  const NovaTheme({
    required this.spaceGradient,
    required this.spark,
    required this.starLit,
    required this.starDim,
    required this.coin,
    required this.stardust,
  });

  /// The standard dark "lofi space" token set.
  factory NovaTheme.dark() => const NovaTheme(
    spaceGradient: AppColors.spaceGradient,
    spark: AppColors.nova500,
    starLit: AppColors.starLit,
    starDim: AppColors.starDim,
    coin: AppColors.coin,
    stardust: AppColors.stardust,
  );

  final LinearGradient spaceGradient;
  final Color spark;
  final Color starLit;
  final Color starDim;
  final Color coin;
  final Color stardust;

  @override
  NovaTheme copyWith({
    LinearGradient? spaceGradient,
    Color? spark,
    Color? starLit,
    Color? starDim,
    Color? coin,
    Color? stardust,
  }) {
    return NovaTheme(
      spaceGradient: spaceGradient ?? this.spaceGradient,
      spark: spark ?? this.spark,
      starLit: starLit ?? this.starLit,
      starDim: starDim ?? this.starDim,
      coin: coin ?? this.coin,
      stardust: stardust ?? this.stardust,
    );
  }

  @override
  NovaTheme lerp(covariant NovaTheme? other, double t) {
    if (other == null) return this;
    return NovaTheme(
      spaceGradient:
          LinearGradient.lerp(spaceGradient, other.spaceGradient, t) ??
          spaceGradient,
      spark: Color.lerp(spark, other.spark, t) ?? spark,
      starLit: Color.lerp(starLit, other.starLit, t) ?? starLit,
      starDim: Color.lerp(starDim, other.starDim, t) ?? starDim,
      coin: Color.lerp(coin, other.coin, t) ?? coin,
      stardust: Color.lerp(stardust, other.stardust, t) ?? stardust,
    );
  }
}
