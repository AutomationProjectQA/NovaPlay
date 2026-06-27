import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/domain/wallet.dart';

/// The result of applying time-based regeneration to a stored lives value.
class RegenResult {
  const RegenResult({required this.lives, required this.lastRegenMs});

  final Lives lives;

  /// The (possibly advanced) regen anchor timestamp to persist.
  final int lastRegenMs;
}

/// Pure lives regeneration (docs/MONETIZATION.md §3.3: 1 / 20 min, cap 5).
///
/// Given the [storedCount], the regen-anchor [lastRegenMs], and [nowMs],
/// computes the current lives, the time until the next life, and the new anchor
/// to persist. Fully deterministic — unit-testable with a fixed clock.
RegenResult regenerateLives({
  required int storedCount,
  required int lastRegenMs,
  required int nowMs,
  int max = EconomyConfig.maxLives,
  Duration interval = EconomyConfig.lifeRegenInterval,
}) {
  final intervalMs = interval.inMilliseconds;

  if (storedCount >= max) {
    return RegenResult(
      lives: Lives(current: storedCount.clamp(0, max), max: max),
      lastRegenMs: nowMs,
    );
  }

  final elapsed = (nowMs - lastRegenMs).clamp(0, 1 << 62);
  final regenerated = elapsed ~/ intervalMs;
  final newCount = (storedCount + regenerated).clamp(0, max);

  if (newCount >= max) {
    return RegenResult(
      lives: Lives(current: max, max: max),
      lastRegenMs: nowMs,
    );
  }

  // Carry forward the remainder so partial progress isn't lost.
  final newAnchor = lastRegenMs + regenerated * intervalMs;
  final remainingMs = intervalMs - (nowMs - newAnchor);

  return RegenResult(
    lives: Lives(
      current: newCount,
      max: max,
      nextRegen: Duration(milliseconds: remainingMs.clamp(0, intervalMs)),
    ),
    lastRegenMs: newAnchor,
  );
}
