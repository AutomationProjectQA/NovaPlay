import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';

/// A dev-only showcase of every design-system component (Sprint 6). Routed at
/// `/gallery` and linked from Home in non-prod flavors. Doubles as a visual QA
/// surface and golden-test target.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _toggle = true;
  double _slider = 0.6;
  int _selectedCard = 0;

  @override
  Widget build(BuildContext context) {
    return NovaScaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _section('Buttons', [
            NovaButton(label: 'Primary', onPressed: () {}),
            const SizedBox(height: AppSpacing.xs),
            NovaButton(
              label: 'Secondary',
              variant: NovaButtonVariant.secondary,
              icon: Icons.play_arrow,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.xs),
            NovaButton(
              label: 'Ghost',
              variant: NovaButtonVariant.ghost,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.xs),
            const NovaButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: AppSpacing.xs),
            const NovaButton(
              label: 'Loading',
              onPressed: _noop,
              isLoading: true,
            ),
          ]),
          _section('HUD', const [
            Row(
              children: [
                SparkCounter(remaining: 3, total: 5),
                SizedBox(width: AppSpacing.lg),
                StarMeter(earned: 41, total: 60),
                Spacer(),
                StarTriad(earned: 2, size: 20),
              ],
            ),
          ]),
          _section('Currency', [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                CurrencyBadge(
                  kind: CurrencyKind.coin,
                  amount: 1240,
                  onAdd: () {},
                ),
                const CurrencyBadge(kind: CurrencyKind.stardust, amount: 86),
                const LivesPill(
                  lives: 3,
                  maxLives: 5,
                  countdown: Duration(minutes: 12, seconds: 30),
                ),
              ],
            ),
          ]),
          _section('Level nodes', [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const LevelNode(
                  levelId: 4,
                  state: LevelNodeState.cleared,
                  sectorAccent: AppColors.sectorEmbers,
                  stars: 3,
                ),
                LevelNode(
                  levelId: 5,
                  state: LevelNodeState.next,
                  sectorAccent: AppColors.sectorEmbers,
                  onTap: () {},
                ),
                const LevelNode(
                  levelId: 6,
                  state: LevelNodeState.locked,
                  sectorAccent: AppColors.sectorEmbers,
                ),
                const LevelNode(
                  levelId: 20,
                  state: LevelNodeState.next,
                  sectorAccent: AppColors.sectorNebula,
                  isFinale: true,
                ),
              ],
            ),
          ]),
          _section('Progress', [
            const NovaProgressBar(value: 0.45),
            const SizedBox(height: AppSpacing.md),
            const XpBar(level: 7, progress: 0.7),
          ]),
          _section('Cards', [
            for (var i = 0; i < 2; i++) ...[
              NovaCard(
                isSelected: _selectedCard == i,
                onTap: () => setState(() => _selectedCard = i),
                child: Text(
                  'Selectable card ${i + 1}',
                  style: context.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ]),
          _section('Controls', [
            Row(
              children: [
                NovaSwitch(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                Expanded(
                  child: NovaSlider(
                    value: _slider,
                    onChanged: (v) => setState(() => _slider = v),
                  ),
                ),
              ],
            ),
          ]),
          _section('Overlays', [
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                NovaButton(
                  label: 'Dialog',
                  expand: false,
                  variant: NovaButtonVariant.secondary,
                  onPressed: _showDialog,
                ),
                NovaButton(
                  label: 'Sheet',
                  expand: false,
                  variant: NovaButtonVariant.secondary,
                  onPressed: _showSheet,
                ),
                NovaButton(
                  label: 'Toast',
                  expand: false,
                  variant: NovaButtonVariant.secondary,
                  onPressed: () => showNovaSnackBar(
                    context,
                    message: 'Synced',
                    status: NovaSnackStatus.success,
                  ),
                ),
              ],
            ),
          ]),
          _section('Loading & states', [
            const NovaSkeleton(),
            const SizedBox(height: AppSpacing.xs),
            const NovaSkeleton(width: 180),
            const SizedBox(height: AppSpacing.md),
            const SizedBox(
              height: 200,
              child: NovaStateView(
                kind: NovaStateKind.error,
                title: 'Shop offline',
                message: 'Check your connection and try again.',
                actionLabel: 'Retry',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  static void _noop() {}

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.sm,
          ),
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        ...children,
      ],
    );
  }

  void _showDialog() {
    unawaited(
      showNovaDialog<void>(
        context,
        dialog: const NovaDialog(
          title: 'Leave level?',
          body: Text('Your progress on this level will be lost.'),
          confirmLabel: 'Leave',
          cancelLabel: 'Stay',
        ),
      ),
    );
  }

  void _showSheet() {
    unawaited(
      showNovaSheet<void>(
        context,
        sheet: NovaSheet(
          title: 'Out of lives',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Watch an ad to refill, or wait for regeneration.',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              NovaButton(
                label: 'Watch ad',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
