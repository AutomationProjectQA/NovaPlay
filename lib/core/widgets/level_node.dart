import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/star_widgets.dart';

/// The visual/interaction state of a [LevelNode] (docs/DESIGN_SYSTEM.md §4.8).
enum LevelNodeState { locked, next, cleared }

/// A single level on the sector map: a circular node with a center label, a
/// sector-accent ring, and a 0–3 star arc below. The "next" node breathes
/// (docs/DESIGN_SYSTEM.md §5) unless reduced motion is on.
class LevelNode extends StatefulWidget {
  const LevelNode({
    required this.levelId,
    required this.state,
    required this.sectorAccent,
    this.stars = 0,
    this.isFinale = false,
    this.onTap,
    super.key,
  });

  final int levelId;
  final LevelNodeState state;
  final Color sectorAccent;
  final int stars;

  /// Supernova finale nodes render larger with a stronger glow.
  final bool isFinale;
  final VoidCallback? onTap;

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode>
    with SingleTickerProviderStateMixin {
  AnimationController? _breath;

  bool get _shouldBreath => widget.state == LevelNodeState.next;

  @override
  void initState() {
    super.initState();
    if (_shouldBreath) _startBreathing();
  }

  @override
  void didUpdateWidget(LevelNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _breath?.dispose();
      _breath = null;
      if (_shouldBreath) _startBreathing();
    }
  }

  void _startBreathing() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _breath = controller;
    // repeat() returns a TickerFuture we intentionally don't await.
    // ignore: discarded_futures
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.isFinale ? 72.0 : 56.0;
    final isLocked = widget.state == LevelNodeState.locked;
    final fill = isLocked ? AppColors.surfaceBase : AppColors.surfaceRaised;
    final ringColor = isLocked ? AppColors.onDisabled : widget.sectorAccent;
    final glow = widget.state == LevelNodeState.next || widget.isFinale;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animate = _breath != null && !reduceMotion;

    return Semantics(
      button: !isLocked,
      enabled: !isLocked,
      label: _semanticLabel(isLocked),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isLocked ? null : widget.onTap,
            child: AnimatedBuilder(
              animation: _breath ?? const AlwaysStoppedAnimation(0),
              builder: (context, _) {
                final pulse = animate ? _breath!.value : 0.5;
                final glowAlpha = 0.3 + 0.25 * pulse;
                return Container(
                  width: diameter,
                  height: diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                    border: Border.all(
                      color: ringColor,
                      width: widget.isFinale ? 3 : 2,
                    ),
                    boxShadow: glow
                        ? [
                            BoxShadow(
                              color: widget.sectorAccent.withValues(
                                alpha: glowAlpha,
                              ),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: _label(isLocked)),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (widget.state == LevelNodeState.cleared)
            StarTriad(earned: widget.stars, size: 12)
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Screen-reader description of the node's level, state, and stars.
  String _semanticLabel(bool isLocked) {
    final kind = widget.isFinale ? 'Finale level' : 'Level';
    if (isLocked) return '$kind ${widget.levelId}, locked';
    if (widget.state == LevelNodeState.cleared) {
      return '$kind ${widget.levelId}, cleared, ${widget.stars} of 3 stars';
    }
    return '$kind ${widget.levelId}, play next';
  }

  Widget _label(bool isLocked) {
    if (isLocked) {
      return const Icon(Icons.lock, size: 20, color: AppColors.onDisabled);
    }
    if (widget.isFinale) {
      return const Icon(Icons.auto_awesome, size: 26, color: AppColors.nova500);
    }
    return Text(
      '${widget.levelId}',
      style: const TextStyle(
        color: AppColors.onHigh,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}
