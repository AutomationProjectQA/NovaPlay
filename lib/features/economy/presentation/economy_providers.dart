import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/features/economy/domain/wallet.dart';

/// The player's wallet. Stubbed with starter balances for Sprint 7 so the HUD
/// renders real data; persistence + earning/spending land in Sprint 13.
final walletProvider = Provider<Wallet>((ref) {
  return const Wallet(coins: 1240, stardust: 12);
});

/// The player's lives/energy. Stubbed for Sprint 7; the regeneration timer and
/// persistence land in Sprint 13.
final livesProvider = Provider<Lives>((ref) {
  return const Lives(
    current: 4,
    nextRegen: Duration(minutes: 19, seconds: 58),
  );
});
