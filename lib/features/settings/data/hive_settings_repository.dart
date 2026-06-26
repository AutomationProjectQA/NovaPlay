import 'package:hive/hive.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/features/settings/domain/settings_repository.dart';
import 'package:novaplay/features/settings/domain/settings_state.dart';

/// Hive-backed [SettingsRepository]. Stores the whole settings map under a
/// single key in the already-open settings box (docs/ARCHITECTURE.md §9).
class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._box);

  static const String _key = 'preferences';

  final Box<Object> _box;

  @override
  SettingsState load() {
    final stored = _box.get(_key);
    if (stored is Map) return SettingsState.fromMap(stored);
    return const SettingsState();
  }

  @override
  Future<void> save(SettingsState settings) => _box.put(_key, settings.toMap());
}

/// Opens (or reuses) the settings box. Boxes are opened at bootstrap, so this is
/// synchronous in practice.
Box<Object> settingsBox() => Hive.box<Object>(HiveBoxes.settings);
