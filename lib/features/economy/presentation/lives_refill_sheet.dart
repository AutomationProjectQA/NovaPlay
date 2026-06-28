import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/ads_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/domain/economy_config.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';

/// Plays [gamePath] if the player has lives, otherwise opens the refill sheet
/// (the lives gate, docs/UI_GUIDELINES.md §2.2).
void launchLevelOrRefill(BuildContext context, WidgetRef ref, String gamePath) {
  if (ref.read(livesProvider).isEmpty) {
    unawaited(showLivesRefillSheet(context, ref));
  } else {
    unawaited(context.push(gamePath));
  }
}

/// Bottom sheet offering ways to top up lives: rewarded ad, coins, or a full
/// refill (docs/UI_GUIDELINES.md §2.3, MONETIZATION.md §3.3).
Future<void> showLivesRefillSheet(BuildContext context, WidgetRef ref) {
  return showNovaSheet<void>(
    context,
    sheet: NovaSheet(
      title: 'lives_out'.tr(),
      child: Consumer(
        builder: (context, ref, _) {
          final lives = ref.watch(livesProvider);
          final wallet = ref.watch(walletProvider);
          final full = lives.isFull;

          Future<void> watchAd() async {
            final rewarded = await getIt<AdsService>().showRewarded(
              AdPlacement.rewardedLifeRefill,
            );
            if (rewarded) ref.read(livesProvider.notifier).add(1);
            if (context.mounted) Navigator.of(context).pop();
          }

          void buyOne() {
            if (ref
                .read(walletProvider.notifier)
                .spendCoins(EconomyConfig.coinsPerLifeRefill)) {
              ref.read(livesProvider.notifier).add(1);
              Navigator.of(context).pop();
            } else {
              showNovaSnackBar(
                context,
                message: 'shop_not_enough_coins'.tr(),
                status: NovaSnackStatus.error,
              );
            }
          }

          void buyFull() {
            if (ref
                .read(walletProvider.notifier)
                .spendCoins(EconomyConfig.coinsFullLifeRefill)) {
              ref.read(livesProvider.notifier).refillFull();
              Navigator.of(context).pop();
            } else {
              showNovaSnackBar(
                context,
                message: 'shop_not_enough_coins'.tr(),
                status: NovaSnackStatus.error,
              );
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'lives_count'.tr(args: ['${lives.current}', '${lives.max}']),
              ),
              const SizedBox(height: AppSpacing.md),
              NovaButton(
                label: 'lives_watch_ad'.tr(),
                icon: Icons.play_circle_outline,
                onPressed: full ? null : () => unawaited(watchAd()),
              ),
              const SizedBox(height: AppSpacing.xs),
              NovaButton(
                label: 'lives_buy_one'.tr(
                  args: ['${EconomyConfig.coinsPerLifeRefill}'],
                ),
                variant: NovaButtonVariant.secondary,
                onPressed:
                    full || !wallet.canAfford(EconomyConfig.coinsPerLifeRefill)
                    ? null
                    : buyOne,
              ),
              const SizedBox(height: AppSpacing.xs),
              NovaButton(
                label: 'lives_buy_full'.tr(
                  args: ['${EconomyConfig.coinsFullLifeRefill}'],
                ),
                variant: NovaButtonVariant.secondary,
                onPressed:
                    full || !wallet.canAfford(EconomyConfig.coinsFullLifeRefill)
                    ? null
                    : buyFull,
              ),
            ],
          );
        },
      ),
    ),
  );
}
