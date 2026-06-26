import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/space_background.dart';

/// A full-screen calm loading veil over the space backdrop (DS §4.11). Used for
/// boot/preload and async route transitions. No percentage — just a quiet spark.
class NovaLoadingVeil extends StatelessWidget {
  const NovaLoadingVeil({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.nova500),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: const TextStyle(color: AppColors.onMedium),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A standalone loading route (boot/preload). Wraps [NovaLoadingVeil] in a
/// transparent scaffold so it can be pushed like any screen.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NovaLoadingVeil(message: message),
    );
  }
}
