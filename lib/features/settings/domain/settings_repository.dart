import 'package:novaplay/features/settings/domain/settings_state.dart';

/// Persists and loads [SettingsState]. Implemented over Hive in the data layer.
abstract interface class SettingsRepository {
  /// Reads the stored settings, or defaults if none saved yet.
  SettingsState load();

  /// Persists the given settings.
  Future<void> save(SettingsState settings);
}
