import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/analytics_events.dart';
import 'package:novaplay/core/services/analytics_service.dart';
import 'package:novaplay/core/services/update_gate.dart';
import 'package:novaplay/core/widgets/space_background.dart';
import 'package:novaplay/features/onboarding/presentation/forced_update_screen.dart';
import 'package:novaplay/features/onboarding/presentation/update_providers.dart';

/// Boot screen: the logo "ignites" (fade + scale in) while startup settles, then
/// routes to the home hub (docs/UI_GUIDELINES.md §3.1) — unless the remote kill
/// switch demands a forced update (docs/LIVEOPS.md), in which case it blocks.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    if (ref.read(updateStatusProvider) == UpdateStatus.updateRequired) {
      getIt<AnalyticsService>().logAppUpdatePrompt(status: 'required');
      setState(() => _blocked = true);
      return;
    }
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) return const ForcedUpdateScreen();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SpaceBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, t, child) {
              return Opacity(
                opacity: t,
                child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
              );
            },
            child: Text('app_title'.tr(), style: AppTypography.displayLarge),
          ),
        ),
      ),
    );
  }
}
