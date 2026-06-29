// Bumps the `version:` line in pubspec.yaml (Sprint 22 release tooling).
//
// Usage:
//   dart run tool/bump_version.dart            # patch + build
//   dart run tool/bump_version.dart minor
//   dart run tool/bump_version.dart major
//   dart run tool/bump_version.dart build      # build number only
import 'dart:io';

import 'version.dart';

void main(List<String> args) {
  final bump = parseBumpArg(args.isEmpty ? null : args.first);
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    stderr.writeln('Run from the project root (pubspec.yaml not found).');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final index = lines.indexWhere((l) => l.startsWith('version:'));
  if (index == -1) {
    stderr.writeln('No `version:` line in pubspec.yaml.');
    exit(1);
  }

  final current = lines[index].substring('version:'.length).trim();
  final next = bumpVersion(current, bump);
  lines[index] = 'version: $next';
  file.writeAsStringSync('${lines.join('\n')}\n');

  stdout.writeln('Version: $current -> $next');
  stdout.writeln('Next: update CHANGELOG.md, commit, and tag v$next.');
}
