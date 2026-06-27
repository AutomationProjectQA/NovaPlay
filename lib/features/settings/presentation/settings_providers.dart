import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/settings/data/hive_settings_repository.dart';
import 'package:novaplay/features/settings/domain/settings_repository.dart';
import 'package:novaplay/features/settings/domain/settings_state.dart';

/// Provides the settings persistence implementation.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository(settingsBox());
});

/// The current user settings. Reads persist immediately to the repository.
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// Mutates [SettingsState] and writes through to storage on every change.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => ref.read(settingsRepositoryProvider).load();

  void setMusicVolume(double value) =>
      _update(state.copyWith(musicVolume: value));

  void setSfxVolume(double value) => _update(state.copyWith(sfxVolume: value));

  void setHaptics({required bool enabled}) =>
      _update(state.copyWith(haptics: enabled));

  void setReducedMotion({required bool enabled}) =>
      _update(state.copyWith(reducedMotion: enabled));

  void setLanguage(String languageCode) =>
      _update(state.copyWith(languageCode: languageCode));

  void setTutorialSeen({required bool seen}) =>
      _update(state.copyWith(tutorialSeen: seen));

  void _update(SettingsState next) {
    state = next;
    unawaited(ref.read(settingsRepositoryProvider).save(next));
  }
}
