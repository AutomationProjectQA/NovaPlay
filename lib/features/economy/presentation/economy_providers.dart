import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/economy/data/economy_repository.dart';
import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/domain/lives_math.dart';
import 'package:novaplay/features/economy/domain/player_xp.dart';
import 'package:novaplay/features/economy/domain/wallet.dart';

/// Provides economy persistence.
final economyRepositoryProvider = Provider<EconomyRepository>((ref) {
  return EconomyRepository(economyBox());
});

// ── Wallet (coins + stardust) ──

final walletProvider = NotifierProvider<WalletNotifier, Wallet>(
  WalletNotifier.new,
);

class WalletNotifier extends Notifier<Wallet> {
  EconomyRepository get _repo => ref.read(economyRepositoryProvider);

  @override
  Wallet build() => Wallet(coins: _repo.coins, stardust: _repo.stardust);

  void earnCoins(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(coins: state.coins + amount);
    unawaited(_repo.setCoins(state.coins));
  }

  /// Spends coins; returns false (no change) if unaffordable.
  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (!state.canAfford(amount)) return false;
    state = state.copyWith(coins: state.coins - amount);
    unawaited(_repo.setCoins(state.coins));
    return true;
  }

  void earnStardust(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(stardust: state.stardust + amount);
    unawaited(_repo.setStardust(state.stardust));
  }

  /// Converts stardust to coins at the fixed rate (docs/MONETIZATION.md §3.2).
  bool convertStardust(int stardustAmount) {
    if (stardustAmount <= 0 || state.stardust < stardustAmount) return false;
    state = state.copyWith(
      stardust: state.stardust - stardustAmount,
      coins: state.coins + stardustAmount * EconomyConfig.stardustToCoinsRate,
    );
    unawaited(_repo.setStardust(state.stardust));
    unawaited(_repo.setCoins(state.coins));
    return true;
  }
}

// ── Lives / energy (time-regenerating) ──

final livesProvider = NotifierProvider<LivesNotifier, Lives>(
  LivesNotifier.new,
);

class LivesNotifier extends Notifier<Lives> {
  Timer? _timer;

  EconomyRepository get _repo => ref.read(economyRepositoryProvider);
  int get _nowMs => DateTime.now().millisecondsSinceEpoch;

  @override
  Lives build() {
    ref.onDispose(() => _timer?.cancel());
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    return _evaluate(persist: true);
  }

  Lives _evaluate({bool persist = false}) {
    final stored = _repo.livesCount;
    final anchor = (stored >= EconomyConfig.maxLives || _repo.livesRegenMs == 0)
        ? _nowMs
        : _repo.livesRegenMs;
    final result = regenerateLives(
      storedCount: stored,
      lastRegenMs: anchor,
      nowMs: _nowMs,
    );
    if (persist &&
        (result.lives.current != stored ||
            result.lastRegenMs != _repo.livesRegenMs)) {
      unawaited(_repo.setLives(result.lives.current, result.lastRegenMs));
    }
    return result.lives;
  }

  void _tick() {
    final next = _evaluate(persist: true);
    if (next != state) state = next;
  }

  /// Consumes a life on a failed attempt.
  void consume() {
    if (state.current <= 0) return;
    final newCount = state.current - 1;
    final anchor = state.isFull ? _nowMs : _repo.livesRegenMs;
    unawaited(_repo.setLives(newCount, anchor == 0 ? _nowMs : anchor));
    state = _evaluate();
  }

  /// Adds [count] lives (rewarded ad / coins), capped at max.
  void add(int count) {
    final newCount = (state.current + count).clamp(0, EconomyConfig.maxLives);
    final anchor = newCount >= EconomyConfig.maxLives
        ? _nowMs
        : (_repo.livesRegenMs == 0 ? _nowMs : _repo.livesRegenMs);
    unawaited(_repo.setLives(newCount, anchor));
    state = _evaluate();
  }

  /// Refills to the cap.
  void refillFull() {
    unawaited(_repo.setLives(EconomyConfig.maxLives, _nowMs));
    state = _evaluate();
  }
}

// ── XP / player level ──

final playerXpProvider = NotifierProvider<XpNotifier, PlayerXp>(
  XpNotifier.new,
);

class XpNotifier extends Notifier<PlayerXp> {
  EconomyRepository get _repo => ref.read(economyRepositoryProvider);

  @override
  PlayerXp build() => PlayerXp.fromTotal(_repo.xp);

  void addXp(int amount) {
    if (amount <= 0) return;
    final total = state.totalXp + amount;
    state = PlayerXp.fromTotal(total);
    unawaited(_repo.setXp(total));
  }
}

// ── Boosters inventory ──

final boostersProvider =
    NotifierProvider<BoostersNotifier, Map<BoosterType, int>>(
      BoostersNotifier.new,
    );

class BoostersNotifier extends Notifier<Map<BoosterType, int>> {
  EconomyRepository get _repo => ref.read(economyRepositoryProvider);

  @override
  Map<BoosterType, int> build() {
    final raw = _repo.boosters;
    return {for (final type in BoosterType.values) type: raw[type.key] ?? 0};
  }

  int count(BoosterType type) => state[type] ?? 0;

  void grant(BoosterType type, int amount) {
    state = {...state, type: (state[type] ?? 0) + amount};
    _persist();
  }

  /// Consumes one booster; returns false if none owned.
  bool use(BoosterType type) {
    final owned = state[type] ?? 0;
    if (owned <= 0) return false;
    state = {...state, type: owned - 1};
    _persist();
    return true;
  }

  /// Buys one booster with coins; returns false if unaffordable.
  bool buy(BoosterType type) {
    final price = EconomyConfig.boosterCoinPrice[type] ?? 0;
    if (!ref.read(walletProvider.notifier).spendCoins(price)) return false;
    grant(type, 1);
    return true;
  }

  void _persist() {
    unawaited(
      _repo.setBoosters(state.map((key, value) => MapEntry(key.key, value))),
    );
  }
}
