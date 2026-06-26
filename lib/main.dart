import 'package:novaplay/main_dev.dart' as dev;

/// Default entrypoint (delegates to the dev flavor) so a bare `flutter run`
/// works. CI and release builds target `lib/main_<flavor>.dart` explicitly.
void main() => dev.main();
