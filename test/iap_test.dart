import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/economy/data/economy_repository.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/shop/domain/iap_catalog.dart';
import 'package:novaplay/features/shop/presentation/iap_providers.dart';

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      // In-memory economy repo so grants round-trip without Hive.
      economyRepositoryProvider.overrideWithValue(EconomyRepository(null)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('IAP catalog', () {
    test('product ids are unique', () {
      final ids = kIapCatalog.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('remove_ads is a non-consumable that grants the entitlement', () {
      final p = iapProductById('remove_ads');
      expect(p, isNotNull);
      expect(p!.kind, IapKind.nonConsumable);
      expect(p.grantsRemoveAds, isTrue);
    });

    test('unknown id resolves to null', () {
      expect(iapProductById('nope'), isNull);
    });
  });

  group('grantPurchase', () {
    test('a coin pack credits the wallet', () {
      final c = _container();
      final before = c.read(walletProvider).coins;
      c
          .read(purchaseControllerProvider.notifier)
          .grant(
            iapProductById('coins_large')!,
          );
      expect(c.read(walletProvider).coins, before + 3000);
    });

    test('the starter bundle grants coins and boosters', () {
      final c = _container();
      final before = c.read(walletProvider).coins;
      c
          .read(purchaseControllerProvider.notifier)
          .grant(
            iapProductById('starter_bundle')!,
          );
      expect(c.read(walletProvider).coins, before + 1000);
      expect(c.read(boostersProvider).values.fold<int>(0, (a, b) => a + b), 6);
    });

    test('remove_ads flips the entitlement and persists it', () {
      final c = _container();
      expect(c.read(removeAdsProvider), isFalse);
      c
          .read(purchaseControllerProvider.notifier)
          .grant(
            iapProductById('remove_ads')!,
          );
      expect(c.read(removeAdsProvider), isTrue);
      expect(c.read(economyRepositoryProvider).removeAds, isTrue);
    });
  });
}
