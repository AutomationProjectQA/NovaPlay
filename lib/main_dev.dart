import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/bootstrap.dart';

/// Entrypoint for the development flavor.
/// Run with: `flutter run -t lib/main_dev.dart --flavor dev`
Future<void> main() => bootstrap(AppEnvironment.dev());
