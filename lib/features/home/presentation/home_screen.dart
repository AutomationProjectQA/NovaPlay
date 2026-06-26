import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';

/// The main menu / hub. Sector map and currency HUD are added in Sprint 7+.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'app_title'.tr(),
              textAlign: TextAlign.center,
              style: AppTypography.displayLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'app_tagline'.tr(),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => context.push(Routes.levelSelect),
              child: Text('home_play'.tr()),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push(Routes.profile),
              child: Text('home_profile'.tr()),
            ),
            TextButton(
              onPressed: () => context.push(Routes.settings),
              child: Text('home_settings'.tr()),
            ),
            if (!AppEnvironment.instance.isProd)
              TextButton(
                onPressed: () => context.push(Routes.gallery),
                child: const Text('Design System'),
              ),
          ],
        ),
      ),
    );
  }
}
