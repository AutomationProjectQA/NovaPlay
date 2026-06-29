import 'package:flutter_test/flutter_test.dart';

import '../tool/version.dart';

void main() {
  group('bumpVersion', () {
    test('patch advances patch and build', () {
      expect(bumpVersion('1.0.0+1', VersionBump.patch), '1.0.1+2');
    });

    test('minor advances minor, resets patch, bumps build', () {
      expect(bumpVersion('1.2.3+9', VersionBump.minor), '1.3.0+10');
    });

    test('major advances major, resets minor+patch, bumps build', () {
      expect(bumpVersion('1.2.3+9', VersionBump.major), '2.0.0+10');
    });

    test('build only increments the build number', () {
      expect(bumpVersion('1.0.0+5', VersionBump.build), '1.0.0+6');
    });

    test('a missing build suffix is treated as 0', () {
      expect(bumpVersion('1.0.0', VersionBump.patch), '1.0.1+1');
    });

    test('rejects a malformed version', () {
      expect(
        () => bumpVersion('1.0', VersionBump.patch),
        throwsFormatException,
      );
    });
  });

  group('parseBumpArg', () {
    test('defaults to patch', () {
      expect(parseBumpArg(null), VersionBump.patch);
      expect(parseBumpArg('patch'), VersionBump.patch);
    });

    test('maps known bumps', () {
      expect(parseBumpArg('major'), VersionBump.major);
      expect(parseBumpArg('minor'), VersionBump.minor);
      expect(parseBumpArg('build'), VersionBump.build);
    });

    test('throws on an unknown bump', () {
      expect(() => parseBumpArg('huge'), throwsArgumentError);
    });
  });
}
