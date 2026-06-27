import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/nova_game.dart';
import 'package:novaplay/game/physics/physics_constants.dart';
import 'package:novaplay/game/session/game_session_controller.dart';
import 'package:novaplay/game/session/game_state.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

LevelDefinition _oneStarLevel() => const LevelDefinition(
  id: 1,
  sector: 1,
  sparks: 3,
  parForThreeStars: 3,
  stars: [LevelElement(type: 'star', x: 50, y: 80)],
  elements: [],
);

Future<void> _pumpUntilLoaded(WidgetTester tester, NovaGame game) async {
  for (var i = 0; i < 60 && !game.isLoaded; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('NovaGame mounts and lays out the level', (tester) async {
    final controller = GameSessionController(
      levelId: 1,
      initial: GameState.initial(sparks: 3, starsTotal: 1, parForThreeStars: 3),
    );
    final game = NovaGame(level: _oneStarLevel(), controller: controller);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<NovaGame>(game: game)),
      ),
    );
    await _pumpUntilLoaded(tester, game);

    expect(game.isLoaded, isTrue);
    expect(controller.value.status, GameStatus.aiming);
  });

  testWidgets('launching the spark lights the star and wins the level', (
    tester,
  ) async {
    final controller = GameSessionController(
      levelId: 1,
      initial: GameState.initial(sparks: 3, starsTotal: 1, parForThreeStars: 3),
    );
    final game = NovaGame(level: _oneStarLevel(), controller: controller);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<NovaGame>(game: game)),
      ),
    );
    await _pumpUntilLoaded(tester, game);

    // Pull straight down well past the anchor (full power) so the spark
    // launches straight up toward the star above the slingshot.
    const mid = PhysicsConstants.boardWidth / 2;
    game
      ..aimStart(Vector2(mid, 158))
      ..aimUpdate(Vector2(mid, 230))
      ..aimEnd();

    expect(controller.value.status, GameStatus.shooting);
    expect(controller.value.sparksRemaining, 2);

    // Drive the fixed-step loop directly (widget-test tickers don't advance the
    // Flame loop reliably).
    for (var i = 0; i < 400 && !controller.value.isOver; i++) {
      game.update(1 / 60);
    }

    expect(controller.value.starsLit, 1);
    expect(controller.value.status, GameStatus.won);
  });

  testWidgets('undo rewinds the last shot: spark restored, star re-dimmed', (
    tester,
  ) async {
    // Two stars so lighting one does not win; the level stays in progress.
    const level = LevelDefinition(
      id: 1,
      sector: 1,
      sparks: 3,
      parForThreeStars: 3,
      stars: [
        LevelElement(type: 'star', x: 50, y: 80),
        LevelElement(type: 'star', x: 10, y: 20),
      ],
      elements: [],
    );
    final controller = GameSessionController(
      levelId: 1,
      initial: GameState.initial(sparks: 3, starsTotal: 2, parForThreeStars: 3),
    );
    final game = NovaGame(level: level, controller: controller);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<NovaGame>(game: game)),
      ),
    );
    await _pumpUntilLoaded(tester, game);

    const mid = PhysicsConstants.boardWidth / 2;
    game
      ..aimStart(Vector2(mid, 158))
      ..aimUpdate(Vector2(mid, 230))
      ..aimEnd();
    for (
      var i = 0;
      i < 400 && controller.value.status != GameStatus.aiming;
      i++
    ) {
      game.update(1 / 60);
    }

    expect(controller.value.starsLit, 1);
    expect(controller.value.sparksRemaining, 2);
    expect(game.canUndo, isTrue);

    game.undo();

    expect(controller.value.starsLit, 0);
    expect(controller.value.sparksRemaining, 3);
    expect(controller.value.status, GameStatus.aiming);
    expect(game.canUndo, isFalse);
  });

  testWidgets('restart clears progress back to the initial state', (
    tester,
  ) async {
    final controller = GameSessionController(
      levelId: 1,
      initial: GameState.initial(sparks: 3, starsTotal: 1, parForThreeStars: 3),
    );
    final game = NovaGame(level: _oneStarLevel(), controller: controller);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<NovaGame>(game: game)),
      ),
    );
    await _pumpUntilLoaded(tester, game);

    const mid = PhysicsConstants.boardWidth / 2;
    game
      ..aimStart(Vector2(mid, 158))
      ..aimUpdate(Vector2(mid, 230))
      ..aimEnd();
    for (var i = 0; i < 400 && !controller.value.isOver; i++) {
      game.update(1 / 60);
    }
    expect(controller.value.status, GameStatus.won);

    game.restartLevel();

    expect(controller.value.status, GameStatus.aiming);
    expect(controller.value.starsLit, 0);
    expect(controller.value.sparksRemaining, 3);
    expect(game.canUndo, isFalse);
  });
}
