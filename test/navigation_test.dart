// Test ergonomics: spelling out default field values documents the fixture.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/features/levels/domain/sector.dart';
import 'package:novaplay/features/levels/presentation/levels_providers.dart';
import 'package:novaplay/features/progress/data/progress_repository.dart';
import 'package:novaplay/features/progress/presentation/progress_providers.dart';
import 'package:novaplay/features/settings/domain/settings_state.dart';

void main() {
  group('Sector', () {
    test('computes star totals and progress', () {
      const sector = Sector(
        id: 1,
        name: 'Embers',
        accent: Color(0xFFFF8A5C),
        firstLevel: 1,
        lastLevel: 20,
        starsEarned: 30,
        unlocked: true,
      );
      expect(sector.levelCount, 20);
      expect(sector.starsTotal, 60);
      expect(sector.progress, closeTo(0.5, 0.0001));
    });
  });

  group('sectorsProvider', () {
    test('exposes five sectors; only sector 1 unlocked with no progress', () {
      final container = ProviderContainer(
        overrides: [
          progressRepositoryProvider.overrideWithValue(
            ProgressRepository(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sectors = container.read(sectorsProvider);
      expect(sectors, hasLength(5));
      expect(sectors.first.name, 'Embers');
      expect(sectors.last.name, 'Singularity');
      expect(sectors.where((s) => s.unlocked).length, 1);
    });
  });

  group('SettingsState', () {
    test('round-trips through a map', () {
      const original = SettingsState(
        musicVolume: 0.3,
        sfxVolume: 0.9,
        haptics: false,
        reducedMotion: true,
        languageCode: 'en',
      );
      final restored = SettingsState.fromMap(original.toMap());
      expect(restored, original);
    });

    test('copyWith overrides only the given field', () {
      const base = SettingsState();
      expect(base.copyWith(haptics: false).haptics, isFalse);
      expect(base.copyWith(haptics: false).musicVolume, base.musicVolume);
    });
  });
}
