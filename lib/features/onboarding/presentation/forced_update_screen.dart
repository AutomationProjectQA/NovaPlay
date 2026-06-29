import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/review_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';

/// Hard kill switch shown when the build is below the minimum supported version
/// (docs/LIVEOPS.md). Blocks all play — the only action is to update.
class ForcedUpdateScreen extends StatelessWidget {
  const ForcedUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: NovaStateView(
                kind: NovaStateKind.error,
                icon: Icons.system_update,
                title: 'update_title'.tr(),
                message: 'update_body'.tr(),
                actionLabel: 'update_button'.tr(),
                onAction: () =>
                    unawaited(getIt<ReviewService>().openStoreListing()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
