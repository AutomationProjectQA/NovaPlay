import 'package:hive_flutter/hive_flutter.dart';
import 'package:novaplay/core/constants/app_constants.dart';

/// Initializes Hive and opens the app's boxes. Values are stored as
/// JSON-encodable maps (no generated adapters), keeping codegen light
/// (docs/ARCHITECTURE.md §9).
abstract final class HiveInit {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Object>(HiveBoxes.progress),
      Hive.openBox<Object>(HiveBoxes.settings),
      Hive.openBox<Object>(HiveBoxes.economy),
      Hive.openBox<Object>(HiveBoxes.levelCache),
      Hive.openBox<Object>(HiveBoxes.session),
      Hive.openBox<Object>(HiveBoxes.rewards),
    ]);
  }
}
