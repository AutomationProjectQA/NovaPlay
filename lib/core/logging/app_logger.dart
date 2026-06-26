import 'package:logger/logger.dart';

/// App-wide logger facade. In production, error/fatal logs are also forwarded
/// to Crashlytics by the crash service (docs/ARCHITECTURE.md §15).
class AppLogger {
  AppLogger() : _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warn(String message) => _logger.w(message);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
