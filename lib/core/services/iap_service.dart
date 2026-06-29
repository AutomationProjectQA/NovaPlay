import 'package:novaplay/features/shop/domain/iap_catalog.dart';

/// A catalog product paired with its localized store price string.
class IapDetails {
  const IapDetails({required this.product, required this.price});

  final IapProduct product;
  final String price;
}

/// Storefront billing, abstracted so the real `in_app_purchase` plugin can be
/// swapped in once products are configured in the consoles (SETUP.md). The app's
/// entitlement persistence lives in the economy repo, not here.
abstract interface class IapService {
  Future<void> init();

  /// The available products with store-localized prices.
  Future<List<IapDetails>> queryProducts();

  /// Starts the purchase flow; resolves true once the purchase completes.
  Future<bool> buy(String productId);

  /// Returns the non-consumable product ids the account owns (for "Restore").
  Future<List<String>> restore();
}

/// In-memory billing used in dev, on web, and in tests. Simulates a successful
/// purchase and tracks owned non-consumables for the session. The real
/// implementation (in_app_purchase) replaces this in prod once store products
/// exist; until then there's no real charge.
class StubIapService implements IapService {
  final Set<String> _owned = {};

  static const Map<String, String> _prices = {
    'coins_small': r'$1.99',
    'coins_large': r'$9.99',
    'starter_bundle': r'$4.99',
    'remove_ads': r'$2.99',
  };

  @override
  Future<void> init() async {}

  @override
  Future<List<IapDetails>> queryProducts() async => [
    for (final product in kIapCatalog)
      IapDetails(product: product, price: _prices[product.id] ?? '—'),
  ];

  @override
  Future<bool> buy(String productId) async {
    final product = iapProductById(productId);
    if (product == null) return false;
    if (product.kind == IapKind.nonConsumable) _owned.add(productId);
    return true;
  }

  @override
  Future<List<String>> restore() async => _owned.toList();
}
