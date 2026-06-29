import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/iap_service.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';
import 'package:novaplay/features/shop/domain/iap_catalog.dart';

/// The store catalog with localized prices (from the platform billing client).
final iapProductsProvider = FutureProvider<List<IapDetails>>((ref) {
  return getIt<IapService>().queryProducts();
});

/// Drives purchases + restores and applies the granted entitlements. State is a
/// monotonically increasing counter so the UI can react to ownership changes.
final purchaseControllerProvider = NotifierProvider<PurchaseController, int>(
  PurchaseController.new,
);

class PurchaseController extends Notifier<int> {
  @override
  int build() => 0;

  /// Runs the purchase flow for [productId]; returns true once it completes and
  /// the entitlement is granted. Call from a UI handler (uses billing via DI).
  Future<bool> buy(String productId) async {
    final product = iapProductById(productId);
    if (product == null) return false;
    final ok = await getIt<IapService>().buy(productId);
    if (ok) grant(product);
    return ok;
  }

  /// Restores previously-owned non-consumables and re-grants them. Returns the
  /// number restored.
  Future<int> restore() async {
    final owned = await getIt<IapService>().restore();
    for (final id in owned) {
      final product = iapProductById(id);
      if (product != null) grant(product);
    }
    return owned.length;
  }

  /// Applies a product's entitlements: coins + boosters via the shared
  /// [applyReward] path, and the remove-ads flag. Pure w.r.t. the store, so it's
  /// directly unit-testable; call only after billing confirms the purchase.
  void grant(IapProduct product) {
    if (product.coins > 0 || product.boosters.isNotEmpty) {
      applyReward(
        ref,
        Reward(coins: product.coins, boosters: product.boosters),
      );
    }
    if (product.grantsRemoveAds) ref.read(removeAdsProvider.notifier).enable();
    state++;
  }
}
