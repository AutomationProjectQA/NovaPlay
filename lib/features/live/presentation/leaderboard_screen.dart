import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/services/leaderboard_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/live/presentation/leaderboard_provider.dart';

/// Ranked leaderboard (by total stars). A full-screen leaf reached from Profile.
/// Backed by a local field until a Firestore leaderboard is connected.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider);
    return NovaScaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) => _Row(entry: entries[index]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return NovaCard(
      isSelected: entry.isPlayer,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: context.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.name,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: entry.isPlayer ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const Icon(Icons.star, color: AppColors.starLit, size: 18),
          const SizedBox(width: AppSpacing.xxs),
          Text('${entry.score}', style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}
