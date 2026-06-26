import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/app/theme/nova_glow.dart';

/// Emphasis variants for [NovaButton] (docs/DESIGN_SYSTEM.md §4.1).
enum NovaButtonVariant { primary, secondary, ghost }

/// The single button used across NovaPlay. Wraps the right Material button per
/// [variant], applies the press micro-interaction (scale 0.97), and supports a
/// width-locked [isLoading] spinner state.
class NovaButton extends StatefulWidget {
  const NovaButton({
    required this.label,
    required this.onPressed,
    this.variant = NovaButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final NovaButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// When true the button stretches to its parent's width.
  final bool expand;

  @override
  State<NovaButton> createState() => _NovaButtonState();
}

class _NovaButtonState extends State<NovaButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _buildContent();
    final button = switch (widget.variant) {
      NovaButtonVariant.primary => FilledButton(
        onPressed: _enabled ? widget.onPressed : null,
        child: child,
      ),
      NovaButtonVariant.secondary => OutlinedButton(
        onPressed: _enabled ? widget.onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onHigh,
          backgroundColor: AppColors.surfaceOverlay,
          side: const BorderSide(color: AppColors.onMedium),
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: child,
      ),
      NovaButtonVariant.ghost => TextButton(
        onPressed: _enabled ? widget.onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.onMedium,
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTypography.labelLarge,
        ),
        child: child,
      ),
    };

    final glow = widget.variant == NovaButtonVariant.primary && _enabled;

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: glow ? NovaGlow.nova(opacity: 0.3) : null,
          ),
          child: SizedBox(
            width: widget.expand ? double.infinity : null,
            child: button,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (widget.icon == null) return Text(widget.label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(widget.label),
      ],
    );
  }
}

/// A compact, transparent glyph button (docs/DESIGN_SYSTEM.md §4.1 Icon).
class NovaIconButton extends StatelessWidget {
  const NovaIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: AppColors.onMedium,
      iconSize: 24,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
