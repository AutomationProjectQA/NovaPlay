import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/nova_button.dart';

/// Whether a [NovaStateView] is showing an empty or an error state.
enum NovaStateKind { empty, error }

/// A calm zero-data / failure placeholder with an optional retry CTA
/// (docs/DESIGN_SYSTEM.md §4.12). Never an alarmist red wall.
class NovaStateView extends StatelessWidget {
  const NovaStateView({
    required this.kind,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final NovaStateKind kind;
  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tint = kind == NovaStateKind.error
        ? AppColors.warn
        : AppColors.onMedium;
    final glyph =
        icon ?? (kind == NovaStateKind.error ? Icons.cloud_off : Icons.inbox);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(glyph, size: 48, color: tint),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              NovaButton(
                label: actionLabel!,
                variant: NovaButtonVariant.secondary,
                expand: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
