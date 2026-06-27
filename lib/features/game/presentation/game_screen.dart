import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/game/presentation/game_overlays.dart';
import 'package:novaplay/features/game/presentation/game_providers.dart';
import 'package:novaplay/features/game/presentation/gameplay_hud.dart';
import 'package:novaplay/features/game/presentation/tutorial_overlay.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/settings/presentation/settings_providers.dart';
import 'package:novaplay/game/nova_game.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/session/game_result.dart';
import 'package:novaplay/game/session/game_session_controller.dart';
import 'package:novaplay/game/session/game_snapshot.dart';
import 'package:novaplay/game/session/game_state.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

/// Loads the level then hands off to [_GamePlayView]. While loading it shows the
/// veil; on failure, the calm error state.
class GameScreen extends ConsumerWidget {
  const GameScreen({required this.levelId, super.key});

  final int levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(levelProvider(levelId))
        .when(
          loading: () => const LoadingScreen(),
          error: (error, _) => ErrorScreen(message: error.toString()),
          data: (level) => _GamePlayView(level: level, levelId: levelId),
        );
  }
}

/// Owns the live play session: the Flame game, the session controller, gesture
/// input, the HUD/overlays, and lifecycle-driven save/resume.
class _GamePlayView extends ConsumerStatefulWidget {
  const _GamePlayView({required this.level, required this.levelId});

  final LevelDefinition level;
  final int levelId;

  @override
  ConsumerState<_GamePlayView> createState() => _GamePlayViewState();
}

class _GamePlayViewState extends ConsumerState<_GamePlayView>
    with WidgetsBindingObserver {
  late final GameSessionController _controller;
  late final NovaGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final snapshot = ref.read(sessionRepositoryProvider).load(widget.levelId);
    var initial = GameState.initial(
      sparks: widget.level.sparks,
      starsTotal: widget.level.stars.length,
      parForThreeStars: widget.level.parForThreeStars,
    );
    if (snapshot != null) {
      initial = initial.copyWith(
        sparksRemaining: snapshot.sparksRemaining,
        starsLit: snapshot.litStarIndices.length,
      );
    }

    _controller = GameSessionController(
      levelId: widget.levelId,
      initial: initial,
      onComplete: _onComplete,
    );
    _game = NovaGame(
      level: widget.level,
      controller: _controller,
      snapshot: snapshot,
      reducedMotion: ref.read(settingsProvider).reducedMotion,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _persistSnapshot();
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _persistSnapshot();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onComplete(GameResult result) {
    // Level finished: drop the resume snapshot and record best stars on a win.
    unawaited(ref.read(sessionRepositoryProvider).clear(widget.levelId));
    if (result.won) {
      ref
          .read(progressProvider.notifier)
          .recordResult(levelId: widget.levelId, stars: result.stars);
    }
  }

  void _persistSnapshot() {
    if (_controller.value.isOver) return;
    final snapshot = GameSnapshot(
      levelId: widget.levelId,
      sparksRemaining: _controller.value.sparksRemaining,
      litStarIndices: _game.litStarIndices(),
    );
    unawaited(ref.read(sessionRepositoryProvider).save(snapshot));
  }

  Vector2 _toLogical(Offset local, double width, double height) {
    return Vector2(
      (local.dx / width * PhysicsConstants.boardWidth).clamp(
        0.0,
        PhysicsConstants.boardWidth,
      ),
      (local.dy / height * PhysicsConstants.boardHeight).clamp(
        0.0,
        PhysicsConstants.boardHeight,
      ),
    );
  }

  void _pause() {
    _controller.pause();
    _persistSnapshot();
  }

  Future<void> _navigateTo(String location) async {
    await ref.read(sessionRepositoryProvider).clear(widget.levelId);
    if (mounted) context.pushReplacement(location);
  }

  /// Restarts the level in place (no reload) and drops any snapshot.
  void _restart() {
    _game.restartLevel();
    unawaited(ref.read(sessionRepositoryProvider).clear(widget.levelId));
  }

  void _completeTutorial() {
    ref.read(settingsProvider.notifier).setTutorialSeen(seen: true);
  }

  @override
  Widget build(BuildContext context) {
    final showTutorial =
        widget.levelId == 1 &&
        !ref.watch(settingsProvider.select((s) => s.tutorialSeen));
    final reducedMotion = ref.watch(
      settingsProvider.select((s) => s.reducedMotion),
    );
    return NovaScaffold(
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio:
                  PhysicsConstants.boardWidth / PhysicsConstants.boardHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return GestureDetector(
                    onPanStart: (d) =>
                        _game.aimStart(_toLogical(d.localPosition, w, h)),
                    onPanUpdate: (d) =>
                        _game.aimUpdate(_toLogical(d.localPosition, w, h)),
                    onPanEnd: (_) => _game.aimEnd(),
                    child: GameWidget<NovaGame>(game: _game),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<GameState>(
              valueListenable: _controller.state,
              builder: (context, state, _) {
                final result = _controller.buildResult();
                final overlay = overlayForStatus(
                  status: state.status,
                  stars: result.stars,
                  coins: result.stars * 40,
                  starsRemaining: state.starsTotal - state.starsLit,
                  reducedMotion: reducedMotion,
                  onNext: () =>
                      _navigateTo(Routes.gamePath(widget.levelId + 1)),
                  onReplay: _restart,
                  onRetry: _restart,
                  onMap: () => context.go(Routes.home),
                  onResume: _controller.resume,
                  onRestart: _restart,
                  onQuit: () => context.go(Routes.home),
                );
                final showActions =
                    !state.isOver && state.status != GameStatus.paused;
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: GameplayHud(
                        levelId: widget.levelId,
                        state: state,
                        onPause: _pause,
                      ),
                    ),
                    if (showActions)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _ActionBar(
                          onHint: _game.showHint,
                          onUndo: _game.canUndo ? _game.undo : null,
                        ),
                      ),
                    if (overlay != null) Positioned.fill(child: overlay),
                  ],
                );
              },
            ),
          ),
          if (showTutorial)
            Positioned.fill(
              child: TutorialOverlay(onDone: _completeTutorial),
            ),
        ],
      ),
    );
  }
}

/// The in-play bottom action tray: Hint and Undo (Rewind). Undo is disabled
/// when there is no shot to rewind (docs/UI_GUIDELINES.md §3.4 booster tray).
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onHint, required this.onUndo});

  final VoidCallback onHint;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NovaButton(
              label: 'game_hint_action'.tr(),
              icon: Icons.lightbulb_outline,
              variant: NovaButtonVariant.secondary,
              expand: false,
              onPressed: onHint,
            ),
            const SizedBox(width: AppSpacing.sm),
            NovaButton(
              label: 'game_undo'.tr(),
              icon: Icons.undo,
              variant: NovaButtonVariant.secondary,
              expand: false,
              onPressed: onUndo,
            ),
          ],
        ),
      ),
    );
  }
}
