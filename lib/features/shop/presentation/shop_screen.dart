import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/services/iap_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';
import 'package:novaplay/features/shop/presentation/iap_providers.dart';

/// Boosters / lives / conversion store. IAP currency packs land in Sprint 16;
/// this ships the coin-spendable economy (docs/MONETIZATION.md §4).
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final boosters = ref.watch(boostersProvider);

    final removeAds = ref.watch(removeAdsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SectionTitle('shop_premium'.tr()),
        ref
            .watch(iapProductsProvider)
            .when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (products) => Column(
                children: [
                  for (final d in products)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _IapTile(
                        details: d,
                        owned: d.product.grantsRemoveAds && removeAds,
                        onBuy: () => unawaited(_buyProduct(context, ref, d)),
                      ),
                    ),
                ],
              ),
            ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle('shop_boosters'.tr()),
        for (final type in BoosterType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _BoosterTile(
              type: type,
              owned: boosters[type] ?? 0,
              affordable: wallet.canAfford(
                EconomyConfig.boosterCoinPrice[type] ?? 0,
              ),
              onBuy: () {
                final ok = ref.read(boostersProvider.notifier).buy(type);
                showNovaSnackBar(
                  context,
                  message: ok
                      ? 'shop_purchased'.tr(args: [type.labelKey.tr()])
                      : 'shop_not_enough_coins'.tr(),
                  status: ok ? NovaSnackStatus.success : NovaSnackStatus.error,
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle('shop_lives'.tr()),
        NovaCard(
          child: Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'shop_refill_lives'.tr(),
                  style: context.textTheme.bodyLarge,
                ),
              ),
              NovaButton(
                label: 'common_refill'.tr(),
                variant: NovaButtonVariant.secondary,
                expand: false,
                onPressed: () => unawaited(showLivesRefillSheet(context, ref)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle('shop_convert'.tr()),
        NovaCard(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.stardust),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'shop_convert_desc'.tr(
                    args: ['${EconomyConfig.stardustToCoinsRate}'],
                  ),
                  style: context.textTheme.bodyMedium,
                ),
              ),
              NovaButton(
                label: 'common_convert'.tr(),
                variant: NovaButtonVariant.secondary,
                expand: false,
                onPressed: wallet.stardust > 0
                    ? () {
                        ref.read(walletProvider.notifier).convertStardust(1);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _buyProduct(
    BuildContext context,
    WidgetRef ref,
    IapDetails details,
  ) async {
    final ok = await ref
        .read(purchaseControllerProvider.notifier)
        .buy(details.product.id);
    if (!context.mounted) return;
    showNovaSnackBar(
      context,
      message: ok
          ? 'shop_purchased'.tr(args: [details.product.titleKey.tr()])
          : 'shop_not_enough_coins'.tr(),
      status: ok ? NovaSnackStatus.success : NovaSnackStatus.error,
    );
  }
}

class _IapTile extends StatelessWidget {
  const _IapTile({
    required this.details,
    required this.owned,
    required this.onBuy,
  });

  final IapDetails details;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      child: Row(
        children: [
          Icon(
            details.product.grantsRemoveAds
                ? Icons.block
                : Icons.workspace_premium,
            color: AppColors.nova500,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              details.product.titleKey.tr(),
              style: context.textTheme.titleMedium,
            ),
          ),
          if (owned)
            Text(
              'shop_owned_tag'.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
              ),
            )
          else
            NovaButton(
              label: details.price,
              variant: NovaButtonVariant.secondary,
              expand: false,
              onPressed: onBuy,
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.bodyMedium?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}

class _BoosterTile extends StatelessWidget {
  const _BoosterTile({
    required this.type,
    required this.owned,
    required this.affordable,
    required this.onBuy,
  });

  final BoosterType type;
  final int owned;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final price = EconomyConfig.boosterCoinPrice[type] ?? 0;
    return NovaCard(
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.nova500),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: context.textTheme.titleMedium),
                Text('Owned: $owned', style: context.textTheme.bodyMedium),
              ],
            ),
          ),
          NovaButton(
            label: '$price 🪙',
            variant: NovaButtonVariant.secondary,
            expand: false,
            onPressed: affordable ? onBuy : null,
          ),
        ],
      ),
    );
  }
}
