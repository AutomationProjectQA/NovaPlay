import 'package:hive/hive.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';

/// Persists all economy state — coins, stardust, XP, lives, boosters — to the
/// Hive `economy` box (docs/ARCHITECTURE.md §9). A null [_box] uses an in-memory
/// store instead (tests), so reads/writes still round-trip without Hive.
class EconomyRepository {
  EconomyRepository(this._box);

  final Box<Object>? _box;
  final Map<String, Object> _memory = {};

  Object? _get(String key) => _box != null ? _box.get(key) : _memory[key];

  Future<void> _put(String key, Object value) async {
    if (_box != null) {
      await _box.put(key, value);
    } else {
      _memory[key] = value;
    }
  }

  int _getInt(String key, int fallback) => _get(key) as int? ?? fallback;

  int get coins => _getInt('coins', EconomyConfig.startingCoins);
  Future<void> setCoins(int value) => _put('coins', value);

  int get stardust => _getInt('stardust', EconomyConfig.startingStardust);
  Future<void> setStardust(int value) => _put('stardust', value);

  int get xp => _getInt('xp', 0);
  Future<void> setXp(int value) => _put('xp', value);

  int get livesCount => _getInt('lives', EconomyConfig.maxLives);
  int get livesRegenMs => _getInt('lives_regen_ms', 0);

  Future<void> setLives(int count, int regenMs) async {
    await _put('lives', count);
    await _put('lives_regen_ms', regenMs);
  }

  Map<String, int> get boosters {
    final stored = _get('boosters');
    if (stored is! Map) return {};
    return stored.map((key, value) => MapEntry(key as String, value as int));
  }

  Future<void> setBoosters(Map<String, int> value) => _put('boosters', value);
}

/// Opens (or reuses) the economy box, opened at bootstrap.
Box<Object> economyBox() => Hive.box<Object>(HiveBoxes.economy);
