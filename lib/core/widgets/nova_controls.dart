import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// Themed boolean toggle for settings (docs/DESIGN_SYSTEM.md §4.10).
class NovaSwitch extends StatelessWidget {
  const NovaSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.nova500,
      activeThumbColor: AppColors.space900,
      inactiveTrackColor: AppColors.surfaceOverlay,
      inactiveThumbColor: AppColors.onMedium,
    );
  }
}

/// Themed continuous slider for volume-style prefs (docs/DESIGN_SYSTEM.md §4.10).
class NovaSlider extends StatelessWidget {
  const NovaSlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    super.key,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.nova500,
        inactiveTrackColor: AppColors.surfaceOverlay,
        thumbColor: AppColors.nova400,
        overlayColor: const Color(0x33FFC857),
      ),
      child: Slider(value: value, onChanged: onChanged, min: min, max: max),
    );
  }
}
