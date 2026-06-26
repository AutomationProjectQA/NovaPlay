import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/bootstrap.dart';

/// Entrypoint for the production (store) flavor.
/// Run with: `flutter run -t lib/main_prod.dart --flavor prod`
Future<void> main() => bootstrap(AppEnvironment.prod());
