import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';

/// Status tint for a [showNovaSnackBar] toast.
enum NovaSnackStatus { success, info, error }

/// Shows a transient, non-blocking confirmation toast
/// (docs/DESIGN_SYSTEM.md §4.5).
void showNovaSnackBar(
  BuildContext context, {
  required String message,
  NovaSnackStatus status = NovaSnackStatus.info,
}) {
  final (icon, tint) = switch (status) {
    NovaSnackStatus.success => (Icons.check_circle, AppColors.success),
    NovaSnackStatus.info => (Icons.info, AppColors.info),
    NovaSnackStatus.error => (Icons.error, AppColors.error),
  };

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceOverlay,
        duration: const Duration(milliseconds: 3500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        content: Row(
          children: [
            Icon(icon, color: tint, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.onHigh),
              ),
            ),
          ],
        ),
      ),
    );
}
