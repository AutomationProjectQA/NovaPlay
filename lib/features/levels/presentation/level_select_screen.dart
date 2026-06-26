import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';

/// Placeholder level grid. Sprint 10 replaces this with sector maps, unlock
/// gating, and per-level star ratings loaded from progress.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const int _previewLevelCount = 20;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text('levels_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GridView.builder(
          itemCount: _previewLevelCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
          ),
          itemBuilder: (context, index) {
            final levelId = index + 1;
            return _LevelNode(
              levelId: levelId,
              onTap: () => context.push(Routes.gamePath(levelId)),
            );
          },
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({required this.levelId, required this.onTap});

  final int levelId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            '$levelId',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
