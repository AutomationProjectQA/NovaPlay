import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/bootstrap.dart';

/// Entrypoint for the staging / QA flavor.
/// Run with: `flutter run -t lib/main_staging.dart --flavor staging`
Future<void> main() => bootstrap(AppEnvironment.staging());
