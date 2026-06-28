import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/physics/physics_constants.dart';

const double _w = PhysicsConstants.boardWidth;
const double _h = PhysicsConstants.boardHeight;

void main() {
  group('generated level assets', () {
    test('all 100 levels exist, parse, and are sane', () {
      for (var id = 1; id <= 100; id++) {
        final sector = ((id - 1) ~/ 20) + 1;
        final path =
            'assets/levels/sector_${_pad(sector, 2)}/level_${_pad(id, 3)}.json';
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'missing $path');

        final level = LevelDefinition.fromJson(
          json.decode(file.readAsStringSync()) as Map<String, dynamic>,
        );

        expect(level.id, id);
        expect(level.sector, sector);
        expect(level.stars, isNotEmpty, reason: 'level $id has no stars');
        // Generous enough to be solvable: at least one spark per star.
        expect(
          level.sparks,
          greaterThanOrEqualTo(level.stars.length),
          reason: 'level $id under-budgeted',
        );
        expect(level.parForThreeStars, lessThanOrEqualTo(level.sparks));

        for (final star in level.stars) {
          expect(star.x, inInclusiveRange(0, _w));
          expect(star.y, inInclusiveRange(0, _h));
        }
        for (final element in level.elements) {
          expect(element.x, inInclusiveRange(0, _w));
          expect(element.y, inInclusiveRange(0, _h));
        }
      }
    });

    test(
      'difficulty trends up: late levels have >= as many stars as early',
      () {
        final firstLevel = _load(1);
        final lastSectorFinale = _load(100);
        expect(
          lastSectorFinale.stars.length,
          greaterThan(firstLevel.stars.length),
        );
      },
    );

    // Guards the Sprint 18 asset-compression deliverable (docs/PERFORMANCE.md
    // §6): the bundled JSON must stay minified, never pretty-printed.
    test('level assets are minified (no pretty-print whitespace)', () {
      final raw = File(
        'assets/levels/sector_01/level_001.json',
      ).readAsStringSync();
      expect(raw.contains('\n'), isFalse, reason: 'level JSON is not minified');
      expect(raw.contains(': '), isFalse, reason: 'level JSON is not minified');
    });
  });
}

LevelDefinition _load(int id) {
  final sector = ((id - 1) ~/ 20) + 1;
  final path =
      'assets/levels/sector_${_pad(sector, 2)}/level_${_pad(id, 3)}.json';
  return LevelDefinition.fromJson(
    json.decode(File(path).readAsStringSync()) as Map<String, dynamic>,
  );
}

String _pad(int value, int width) => value.toString().padLeft(width, '0');
