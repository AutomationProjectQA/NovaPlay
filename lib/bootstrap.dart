import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/app.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/persistence/hive_init.dart';

/// Shared async startup used by every flavor entrypoint
/// (`lib/main_<flavor>.dart`). Performs one-time init then mounts the app.
///
/// Firebase/AdMob real initialization is added in their respective sprints and
/// guarded by [AppEnvironment]; the scaffold runs fully without credentials.
Future<void> bootstrap(AppEnvironment env) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.init(env);

  await EasyLocalization.ensureInitialized();
  await HiveInit.initialize();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: NovaApp()),
    ),
  );
}
