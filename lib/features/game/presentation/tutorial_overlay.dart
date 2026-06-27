import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/widgets/widgets.dart';

/// Minimal one-time Level 1 coach marks (docs/GAME_DESIGN.md §6.4 "teach by
/// level design"). A light bottom card the player taps through; the trajectory
/// preview does the real teaching. Calls [onDone] when finished/skipped.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  static const List<String> _stepKeys = [
    'tutorial_step_aim',
    'tutorial_step_release',
    'tutorial_step_light',
  ];

  int _index = 0;

  void _next() {
    if (_index >= _stepKeys.length - 1) {
      widget.onDone();
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _stepKeys.length - 1;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: NovaCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_index + 1} / ${_stepKeys.length}',
                    style: context.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Text(
                      'tutorial_skip'.tr(),
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _stepKeys[_index].tr(),
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              NovaButton(
                label: (isLast ? 'tutorial_got_it' : 'tutorial_next').tr(),
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
