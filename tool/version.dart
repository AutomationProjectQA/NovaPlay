// Pure version math for pubspec `version: X.Y.Z+build` strings (Sprint 22).
// Kept dependency-free so it's unit-testable from test/version_test.dart.

/// Which part of the semantic version to advance. The build number always
/// increments regardless (stores reject re-used build numbers).
enum VersionBump { major, minor, patch, build }

/// Bumps [current] (e.g. `1.2.3+9`) per [bump] and returns the new string.
/// A missing `+build` is treated as build 0. Throws [FormatException] on a
/// malformed input.
String bumpVersion(String current, VersionBump bump) {
  final plus = current.split('+');
  final core = plus[0].split('.');
  if (core.length != 3) {
    throw FormatException('Expected X.Y.Z[+build], got "$current"');
  }
  var major = int.parse(core[0]);
  var minor = int.parse(core[1]);
  var patch = int.parse(core[2]);
  var build = plus.length > 1 ? int.parse(plus[1]) : 0;

  switch (bump) {
    case VersionBump.major:
      major++;
      minor = 0;
      patch = 0;
    case VersionBump.minor:
      minor++;
      patch = 0;
    case VersionBump.patch:
      patch++;
    case VersionBump.build:
      break;
  }
  build++; // store-required: every upload needs a higher build number.
  return '$major.$minor.$patch+$build';
}

/// Parses a `--bump` CLI argument into a [VersionBump] (defaults to patch).
VersionBump parseBumpArg(String? arg) => switch (arg) {
  null || 'patch' => VersionBump.patch,
  'major' => VersionBump.major,
  'minor' => VersionBump.minor,
  'build' => VersionBump.build,
  _ => throw ArgumentError(
    'Unknown bump "$arg" (use: major | minor | patch | build)',
  ),
};
