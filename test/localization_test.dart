// Sprint 20 (Localization) — guards the translation catalogs. Every supported
// locale must define exactly the same keys (no missing or stray translations)
// and no value may be empty. Catches the classic "added an English key, forgot
// the others" regression at test time instead of at runtime.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _locales = ['en', 'es', 'ar'];

Map<String, dynamic> _load(String code) =>
    json.decode(File('assets/translations/$code.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('translation catalogs', () {
    final catalogs = {for (final c in _locales) c: _load(c)};
    final enKeys = catalogs['en']!.keys.toSet();

    test('every locale file parses and is non-empty', () {
      for (final code in _locales) {
        expect(catalogs[code], isNotEmpty, reason: '$code.json is empty');
      }
    });

    test('all locales define exactly the English key set', () {
      for (final code in _locales.where((c) => c != 'en')) {
        final keys = catalogs[code]!.keys.toSet();
        expect(
          keys.difference(enKeys),
          isEmpty,
          reason: '$code has keys missing from en',
        );
        expect(
          enKeys.difference(keys),
          isEmpty,
          reason: '$code is missing keys present in en',
        );
      }
    });

    test('no translation value is blank', () {
      for (final code in _locales) {
        catalogs[code]!.forEach((key, value) {
          if (value is String) {
            expect(value.trim(), isNotEmpty, reason: '$code.$key is blank');
          } else if (value is Map) {
            // Plural form (one/other/...).
            value.forEach((form, text) {
              expect(
                (text as String).trim(),
                isNotEmpty,
                reason: '$code.$key.$form is blank',
              );
            });
          }
        });
      }
    });

    test('plural keys expose the same forms across locales', () {
      final pluralKeys = enKeys.where((k) => catalogs['en']![k] is Map);
      for (final key in pluralKeys) {
        final enForms = (catalogs['en']![key] as Map).keys.toSet();
        for (final code in _locales) {
          expect(
            catalogs[code]![key],
            isA<Map<String, dynamic>>(),
            reason: '$code.$key should be a plural map',
          );
          expect(
            (catalogs[code]![key] as Map).keys.toSet(),
            enForms,
            reason: '$code.$key plural forms differ from en',
          );
        }
      }
    });
  });
}
