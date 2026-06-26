import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_typography.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';

/// First screen shown at launch. Plays the brand moment, then routes to home.
/// First-run onboarding/consent/anonymous-auth is layered on in a later sprint.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_goHome());
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      body: Center(
        child: Text('NovaPlay', style: AppTypography.displayLarge),
      ),
    );
  }
}
