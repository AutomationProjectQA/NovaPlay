import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/presentation/economy_providers.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';

/// The persistent top HUD on hub screens: settings gear · coins · stardust ·
/// lives pill (docs/UI_GUIDELINES.md §1, §3.2). Hidden during gameplay.
class HubTopBar extends ConsumerWidget {
  const HubTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final lives = ref.watch(livesProvider);

    return Padding(
      // Directional so the asymmetric start/end padding mirrors in RTL.
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          NovaIconButton(
            icon: Icons.settings,
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(Routes.shop),
            child: CurrencyBadge(kind: CurrencyKind.coin, amount: wallet.coins),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => context.go(Routes.shop),
            child: CurrencyBadge(
              kind: CurrencyKind.stardust,
              amount: wallet.stardust,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          LivesPill(
            lives: lives.current,
            maxLives: lives.max,
            countdown: lives.nextRegen,
            onTap: () => unawaited(showLivesRefillSheet(context, ref)),
          ),
        ],
      ),
    );
  }
}
