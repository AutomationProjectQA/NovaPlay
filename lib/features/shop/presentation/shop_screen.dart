import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/domain/booster.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';

/// Boosters / lives / conversion store. IAP currency packs land in Sprint 16;
/// this ships the coin-spendable economy (docs/MONETIZATION.md §4).
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final boosters = ref.watch(boostersProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _SectionTitle('Boosters'),
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
                  message: ok ? '${type.label} purchased' : 'Not enough coins',
                  status: ok ? NovaSnackStatus.success : NovaSnackStatus.error,
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionTitle('Lives'),
        NovaCard(
          child: Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Refill lives', style: context.textTheme.bodyLarge),
              ),
              NovaButton(
                label: 'Refill',
                variant: NovaButtonVariant.secondary,
                expand: false,
                onPressed: () => unawaited(showLivesRefillSheet(context, ref)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionTitle('Convert'),
        NovaCard(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.stardust),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '1 stardust → ${EconomyConfig.stardustToCoinsRate} coins',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              NovaButton(
                label: 'Convert',
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
