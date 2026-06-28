import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/ads_service.dart';
import 'package:novaplay/core/services/analytics_events.dart';
import 'package:novaplay/core/services/analytics_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/economy/presentation/lives_refill_sheet.dart';
import 'package:novaplay/features/live/domain/daily_challenge.dart';
import 'package:novaplay/features/live/presentation/daily_challenge_provider.dart';
import 'package:novaplay/features/rewards/domain/daily_reward.dart';
import 'package:novaplay/features/rewards/domain/mission.dart';
import 'package:novaplay/features/rewards/domain/reward.dart';
import 'package:novaplay/features/rewards/presentation/missions_providers.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';
import 'package:novaplay/features/rewards/presentation/wheel_chest_providers.dart';

/// The Daily hub: login reward + streak, lucky wheel, mystery chest, and daily
/// missions (docs/UI_GUIDELINES.md §1, MONETIZATION.md §8).
class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyRewardProvider);
    final wheelFree = ref.watch(wheelProvider);
    final chestFree = ref.watch(chestProvider);
    final missions = ref.watch(dailyMissionStatesProvider);
    final challenge = ref.watch(dailyChallengeProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _Header('daily_challenge'.tr()),
        NovaCard(
          accent: AppColors.sectorNebula,
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.nova500),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'game_level'.tr(args: ['${challenge.levelId}']),
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      '+${kDailyChallengeReward.summary}',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (challenge.doneToday)
                const Icon(Icons.check_circle, color: AppColors.success)
              else
                NovaButton(
                  label: 'common_play'.tr(),
                  expand: false,
                  onPressed: () => launchLevelOrRefill(
                    context,
                    ref,
                    Routes.gamePath(challenge.levelId),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Header('daily_reward'.tr()),
        NovaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'daily_streak'.plural(daily.streak),
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var day = 1; day <= kDailyLadder.length; day++)
                    _DayChip(day: day, active: day == daily.claimDay),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              NovaButton(
                label: daily.canClaim
                    ? 'daily_claim_day'.tr(
                        args: ['${daily.claimDay}', daily.reward.summary],
                      )
                    : 'daily_claimed'.tr(),
                icon: Icons.card_giftcard,
                onPressed: daily.canClaim
                    ? () {
                        final reward = ref
                            .read(dailyRewardProvider.notifier)
                            .claim();
                        if (reward != null) {
                          getIt<AnalyticsService>().logDailyRewardClaimed(
                            streakDay: daily.claimDay,
                          );
                        }
                        _claim(context, reward);
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Header('daily_wheel_chest'.tr()),
        Row(
          children: [
            Expanded(
              child: _OpenerCard(
                icon: Icons.casino,
                title: 'daily_lucky_wheel'.tr(),
                buttonLabel: wheelFree
                    ? 'daily_lucky_wheel_spin'.tr()
                    : 'daily_lucky_wheel_ad'.tr(),
                onPressed: () => _spinWheel(context, ref, free: wheelFree),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _OpenerCard(
                icon: Icons.inventory_2,
                title: 'daily_mystery_chest'.tr(),
                buttonLabel: chestFree
                    ? 'daily_mystery_chest_open'.tr()
                    : 'daily_mystery_chest_tomorrow'.tr(),
                onPressed: chestFree
                    ? () => _claim(
                        context,
                        ref.read(chestProvider.notifier).open(),
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Header('daily_missions'.tr()),
        for (final state in missions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MissionTile(
              state: state,
              onClaim: () => _claim(
                context,
                ref.read(missionsProvider.notifier).claim(state.mission.id)
                    ? state.mission.reward
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  void _claim(BuildContext context, Reward? reward) {
    if (reward == null || reward.isEmpty) return;
    unawaited(
      showNovaDialog<void>(
        context,
        dialog: NovaDialog(
          title: 'daily_reward_dialog'.tr(),
          body: Text(reward.summary),
          confirmLabel: 'common_nice'.tr(),
        ),
      ),
    );
  }

  Future<void> _spinWheel(
    BuildContext context,
    WidgetRef ref, {
    required bool free,
  }) async {
    if (free) {
      _claim(context, ref.read(wheelProvider.notifier).spin());
      return;
    }
    final rewarded = await getIt<AdsService>().showRewarded(
      AdPlacement.rewardedFreeBooster,
    );
    if (rewarded && context.mounted) {
      _claim(context, ref.read(wheelProvider.notifier).spin(viaAd: true));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

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

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.active});

  final int day;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.nova500 : AppColors.surfaceOverlay,
      ),
      child: Text(
        '$day',
        style: TextStyle(
          color: active ? AppColors.space900 : AppColors.onMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OpenerCard extends StatelessWidget {
  const _OpenerCard({
    required this.icon,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.nova500, size: 32),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          NovaButton(
            label: buttonLabel,
            variant: NovaButtonVariant.secondary,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.state, required this.onClaim});

  final MissionState state;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'mission_${state.mission.id}'.tr(),
                  style: context.textTheme.bodyLarge,
                ),
              ),
              if (state.claimed)
                const Icon(Icons.check_circle, color: AppColors.success)
              else if (state.canClaim)
                NovaButton(
                  label: 'common_claim'.tr(),
                  expand: false,
                  onPressed: onClaim,
                )
              else
                Text(
                  '${state.progress}/${state.mission.target}',
                  style: context.textTheme.bodyMedium,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          NovaProgressBar(value: state.fraction),
        ],
      ),
    );
  }
}
