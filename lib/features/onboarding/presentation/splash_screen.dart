import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/core/widgets/nova_loading_veil.dart';

/// Boot screen: shows the loading veil while startup work settles, then routes
/// to the home hub (docs/UI_GUIDELINES.md §3.1). First-run onboarding branches
/// in here in a later sprint.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: NovaLoadingVeil(),
    );
  }
}
