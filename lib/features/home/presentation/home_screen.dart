import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';
import 'package:novaplay/features/levels/domain/sector.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/live/domain/game_event.dart';
import 'package:novaplay/features/live/presentation/events_provider.dart';

/// Home / Galaxy Map — the default landing hub. Shows the sectors and the single
/// most prominent action: Continue the next level (docs/UI_GUIDELINES.md §3.2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectors = ref.watch(sectorsProvider);
    final continueLevel = ref.watch(continueLevelProvider);
    final event = ref.watch(activeEventProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Text(
          'app_title'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        _EventBanner(event: event),
        const SizedBox(height: AppSpacing.md),
        NovaButton(
          label: 'home_continue'.tr(args: ['$continueLevel']),
          icon: Icons.play_arrow,
          onPressed: () => launchLevelOrRefill(
            context,
            ref,
            Routes.gamePath(continueLevel),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final sector in sectors) ...[
          _SectorCard(
            sector: sector,
            onTap: sector.unlocked
                ? () => context.push(Routes.levelSelectPath(sector.id))
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({required this.event});

  final GameEvent event;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      accent: event.accent,
      isSelected: event.hasBonus,
      child: Row(
        children: [
          Icon(Icons.celebration, color: event.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: context.textTheme.titleMedium),
                Text(
                  event.description,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (event.hasBonus)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: event.accent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${event.coinMultiplier}×',
                style: const TextStyle(
                  color: AppColors.space900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectorCard extends StatelessWidget {
  const _SectorCard({required this.sector, required this.onTap});

  final Sector sector;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !sector.unlocked;
    return NovaCard(
      onTap: onTap,
      accent: sector.accent,
      child: Row(
        children: [
          Icon(
            locked ? Icons.lock : Icons.auto_awesome,
            color: locked ? AppColors.onDisabled : sector.accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sector.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: locked ? AppColors.onMedium : AppColors.onHigh,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (locked)
                  Text(
                    'home_sector_locked'.tr(),
                    style: context.textTheme.bodyMedium,
                  )
                else
                  NovaProgressBar(
                    value: sector.progress,
                    color: sector.accent,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (!locked)
            StarMeter(earned: sector.starsEarned, total: sector.starsTotal),
        ],
      ),
    );
  }
}
