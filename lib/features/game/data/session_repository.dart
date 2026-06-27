import 'package:hive/hive.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/game/session/game_snapshot.dart';

/// Persists in-flight level snapshots to the Hive `session` box so a level can
/// be resumed after backgrounding or app kill (docs/ARCHITECTURE.md §8.10).
class SessionRepository {
  SessionRepository(this._box);

  final Box<Object> _box;

  String _key(int levelId) => 'level_$levelId';

  Future<void> save(GameSnapshot snapshot) =>
      _box.put(_key(snapshot.levelId), snapshot.toMap());

  GameSnapshot? load(int levelId) {
    final stored = _box.get(_key(levelId));
    return stored is Map ? GameSnapshot.fromMap(stored) : null;
  }

  Future<void> clear(int levelId) => _box.delete(_key(levelId));
}

/// Opens (or reuses) the session box, opened at bootstrap.
Box<Object> sessionBox() => Hive.box<Object>(HiveBoxes.session);
