import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_glow.dart';

/// A raised content container (docs/DESIGN_SYSTEM.md §4.2). Optionally pressable
/// and selectable (selection adds an accent border + faint glow).
class NovaCard extends StatelessWidget {
  const NovaCard({
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.accent,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;

  /// Sector/brand accent for the selected border + glow. Defaults to nova gold.
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.nova500;
    final radius = BorderRadius.circular(AppRadius.md);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isSelected
            ? NovaGlow.sector(accentColor, opacity: 0.3)
            : NovaGlow.elevation1,
      ),
      child: Material(
        color: AppColors.surfaceRaised,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: isSelected
              ? BorderSide(color: accentColor, width: 1.5)
              : const BorderSide(color: Color(0x14FFFFFF)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
