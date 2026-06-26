import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/profile/domain/player_profile.dart';
import 'package:novaplay/features/profile/presentation/profile_providers.dart';

/// Player profile: identity, XP/level, headline stats, achievements, cloud sync
/// (docs/UI_GUIDELINES.md §3.9). Rendered inside the hub shell.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.sm),
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.surfaceRaised,
          child: Icon(Icons.person, size: 44, color: AppColors.nova500),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        XpBar(level: profile.level, progress: profile.xpProgress),
        const SizedBox(height: AppSpacing.lg),
        _StatsRow(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'profile_achievements'.tr().toUpperCase(),
          style: context.textTheme.bodyMedium?.copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.sm),
        NovaCard(
          child: SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'coming_soon'.tr(),
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _CloudSyncRow(),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            iconColor: AppColors.starLit,
            value: '${profile.totalStars}',
            label: 'profile_total_stars'.tr(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome,
            iconColor: AppColors.sectorNebula,
            value: '${profile.starsThisSector}/${profile.starsSectorTotal}',
            label: 'profile_sector_stars'.tr(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: AppColors.sectorEmbers,
            value: '${profile.bestStreak}',
            label: 'profile_best_streak'.tr(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CloudSyncRow extends StatelessWidget {
  const _CloudSyncRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cloud_done, color: AppColors.success, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text('profile_cloud_sync'.tr(), style: context.textTheme.bodyMedium),
      ],
    );
  }
}
