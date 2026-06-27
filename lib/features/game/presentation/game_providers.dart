import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/game/data/session_repository.dart';

/// Provides the in-flight session snapshot persistence (pause/resume).
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(sessionBox());
});
