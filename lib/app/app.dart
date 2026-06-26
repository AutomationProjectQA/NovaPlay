import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/app/router/app_router.dart';
import 'package:novaplay/app/theme/app_theme.dart';

/// Root widget: wires the router, theme, and localization into
/// `MaterialApp.router`. Composition only — no business logic.
class NovaApp extends ConsumerStatefulWidget {
  const NovaApp({super.key});

  @override
  ConsumerState<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends ConsumerState<NovaApp> {
  late final GoRouter _router = AppRouter.build(ref);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppEnvironment.instance.appName,
      debugShowCheckedModeBanner: !AppEnvironment.instance.isProd,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
