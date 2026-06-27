import 'package:hive/hive.dart';
import 'package:novaplay/core/constants/app_constants.dart';

/// Persists best-stars-per-level to the Hive `progress` box
/// (docs/ARCHITECTURE.md §9). Stored as a single `{levelId: stars}` map.
///
/// A null [_box] yields an in-memory, non-persisting repository — used in tests.
class ProgressRepository {
  ProgressRepository(this._box);

  static const String _key = 'level_stars';

  final Box<Object>? _box;

  /// Loads all recorded level stars as `levelId -> bestStars`.
  Map<int, int> loadAll() {
    final stored = _box?.get(_key);
    if (stored is! Map) return {};
    return stored.map(
      (key, value) => MapEntry(int.parse(key as String), value as int),
    );
  }

  /// Persists the full stars map.
  Future<void> saveAll(Map<int, int> stars) async {
    await _box?.put(
      _key,
      stars.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}

/// Opens (or reuses) the progress box, opened at bootstrap.
Box<Object> progressBox() => Hive.box<Object>(HiveBoxes.progress);
