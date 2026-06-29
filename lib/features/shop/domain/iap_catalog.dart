import 'package:novaplay/features/economy/domain/booster.dart';

/// Whether a store product is consumed on use (coin packs) or owned forever
/// (remove-ads, bundles) — drives restore behaviour (docs/MONETIZATION.md §4 IAP).
enum IapKind { consumable, nonConsumable }

/// A purchasable product and the entitlement it grants. The [id] must match the
/// product id configured in Google Play / App Store Connect.
class IapProduct {
  const IapProduct({
    required this.id,
    required this.kind,
    this.coins = 0,
    this.grantsRemoveAds = false,
    this.boosters = const {},
  });

  final String id;
  final IapKind kind;
  final int coins;
  final bool grantsRemoveAds;
  final Map<BoosterType, int> boosters;

  /// Translation key for the display name (resolved with `.tr()` in the UI).
  String get titleKey => 'iap_$id';
}

/// The product catalog. IDs are the contract with the stores — configure the
/// same ids there before going live (docs/RELEASE_PLAN.md, SETUP.md).
const List<IapProduct> kIapCatalog = [
  IapProduct(id: 'coins_small', kind: IapKind.consumable, coins: 500),
  IapProduct(id: 'coins_large', kind: IapKind.consumable, coins: 3000),
  IapProduct(
    id: 'starter_bundle',
    kind: IapKind.nonConsumable,
    coins: 1000,
    boosters: {BoosterType.extraSpark: 3, BoosterType.rewind: 3},
  ),
  IapProduct(
    id: 'remove_ads',
    kind: IapKind.nonConsumable,
    grantsRemoveAds: true,
  ),
];

/// Looks up a catalog product by [id], or null if unknown.
IapProduct? iapProductById(String id) {
  for (final product in kIapCatalog) {
    if (product.id == id) return product;
  }
  return null;
}
