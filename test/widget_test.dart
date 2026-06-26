import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';

void main() {
  group('LevelDefinition', () {
    test('parses a level from JSON', () {
      final json = <String, dynamic>{
        'id': 1,
        'sector': 1,
        'sparks': 5,
        'parForThreeStars': 2,
        'introMechanic': 'aim',
        'stars': <Map<String, dynamic>>[
          {'type': 'star', 'x': 30, 'y': 50},
          {'type': 'star', 'x': 50, 'y': 90},
        ],
        'elements': <Map<String, dynamic>>[],
      };

      final level = LevelDefinition.fromJson(json);

      expect(level.id, 1);
      expect(level.sparks, 5);
      expect(level.stars, hasLength(2));
      expect(level.stars.first.x, 30);
    });
  });

  test('palette exposes the nova accent', () {
    expect(AppColors.nova500, const Color(0xFFFFC857));
  });
}
