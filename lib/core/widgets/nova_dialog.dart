import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/nova_button.dart';

/// A focused decision/result panel (docs/DESIGN_SYSTEM.md §4.3). Use via
/// [showNovaDialog]. Renders a title, body, and an action row.
class NovaDialog extends StatelessWidget {
  const NovaDialog({
    required this.title,
    required this.body,
    this.confirmLabel,
    this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    super.key,
  });

  final String title;
  final Widget body;
  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String? cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceOverlay,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            DefaultTextStyle.merge(
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
              child: body,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (confirmLabel != null)
              NovaButton(
                label: confirmLabel!,
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              ),
            if (cancelLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              NovaButton(
                label: cancelLabel!,
                variant: NovaButtonVariant.ghost,
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows a [NovaDialog] with the standard scale+fade entrance.
Future<T?> showNovaDialog<T>(
  BuildContext context, {
  required NovaDialog dialog,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.space900.withValues(alpha: 0.64),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, _, _) => dialog,
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
