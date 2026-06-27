import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/app/router/app_router.dart';
import 'package:novaplay/app/theme/app_theme.dart';
import 'package:novaplay/core/constants/audio_assets.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/audio_service.dart';
import 'package:novaplay/core/services/haptics_service.dart';
import 'package:novaplay/features/settings/domain/settings_state.dart';
import 'package:novaplay/features/settings/presentation/settings_providers.dart';

/// Root widget: wires the router, theme, and localization into
/// `MaterialApp.router`, and keeps audio/haptics in sync with settings.
/// Composition only — no business logic.
class NovaApp extends ConsumerStatefulWidget {
  const NovaApp({super.key});

  @override
  ConsumerState<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends ConsumerState<NovaApp> {
  late final GoRouter _router = AppRouter.build(ref);

  @override
  void initState() {
    super.initState();
    _applyAudioSettings(ref.read(settingsProvider));
    unawaited(getIt<AudioService>().playMusic(AudioAssets.musicAmbient));
  }

  /// Pushes the current settings into the audio + haptics services.
  void _applyAudioSettings(SettingsState settings) {
    getIt<AudioService>()
      ..setMusicVolume(settings.musicVolume)
      ..setSfxVolume(settings.sfxVolume);
    getIt<HapticsService>().setEnabled(enabled: settings.haptics);
  }

  @override
  Widget build(BuildContext context) {
    // Live-apply settings changes (volume sliders, haptics toggle).
    ref.listen<SettingsState>(
      settingsProvider,
      (_, next) => _applyAudioSettings(next),
    );

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
