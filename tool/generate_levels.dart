// Deterministic level generator for NovaPlay (Sprint 10).
//
// Emits 100 level JSON files under assets/levels/sector_XX/level_XXX.json plus
// the manifest, following the sector schedule and sawtooth difficulty curve in
// docs/LEVEL_DESIGN.md / docs/GAME_DESIGN.md §6. The output is meant as a strong
// on-curve baseline to be hand-tuned, not a substitute for playtesting.
//
// Run:  dart run tool/generate_levels.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const double boardWidth = 100;
const double boardHeight = 160;
const int levelsPerSector = 20;

const List<({String name, String accent})> sectors = [
  (name: 'Embers', accent: '#FF8A5C'),
  (name: 'Nebula', accent: '#C77DFF'),
  (name: 'Void', accent: '#4DA3FF'),
  (name: 'Pulsar', accent: '#3FD0C9'),
  (name: 'Singularity', accent: '#F2F4FF'),
];

/// The mechanic each sector introduces in its first levels (docs/GAME_DESIGN §6.1).
const List<String> sectorIntro = [
  'aim',
  'gravity_well',
  'black_hole',
  'gravity_well',
  'multi_hit',
];

void main() {
  final manifestLevels = <Map<String, dynamic>>[];

  for (var id = 1; id <= 100; id++) {
    final sector = ((id - 1) ~/ levelsPerSector) + 1;
    final idx = ((id - 1) % levelsPerSector) + 1; // 1..20
    final level = _generate(id, sector, idx);

    final dir = Directory('assets/levels/sector_${_pad(sector, 2)}');
    dir.createSync(recursive: true);
    final path = '${dir.path}/level_${_pad(id, 3)}.json';
    // Compact (no whitespace) — these ship in the app bundle, so minify them to
    // cut asset size and parse time (docs/PERFORMANCE.md). Edit via this tool,
    // not by hand.
    File(path).writeAsStringSync(jsonEncode(level));
    manifestLevels.add({'id': id, 'sector': sector, 'path': path});
  }

  final manifest = {
    'schemaVersion': 1,
    'sectors': [
      for (var s = 0; s < sectors.length; s++)
        {
          'id': s + 1,
          'name': sectors[s].name,
          'levelRange': [s * levelsPerSector + 1, (s + 1) * levelsPerSector],
          'accent': sectors[s].accent,
        },
    ],
    'levels': manifestLevels,
  };
  File('assets/levels/levels_manifest.json').writeAsStringSync(
    jsonEncode(manifest),
  );

  stdout.writeln('Generated 100 levels + manifest under assets/levels/.');
}

/// `phase`: 1 teaching (1–3), 2 combine (4–12), 3 challenge (13–18),
/// 4 calm (19), 5 finale (20).
int _phaseOf(int idx) {
  if (idx <= 3) return 1;
  if (idx <= 12) return 2;
  if (idx <= 18) return 3;
  if (idx == 19) return 4;
  return 5;
}

Map<String, dynamic> _generate(int id, int sector, int idx) {
  final rng = Random(id * 92821);
  final phase = _phaseOf(idx);
  final isFinale = phase == 5;

  // Star count grows across sectors; finale adds one. (docs/GAME_DESIGN §6.2)
  var starCount = (2 + (sector - 1)).clamp(2, 5);
  if (phase == 3) starCount += 1;
  if (isFinale) starCount += 1;
  starCount = starCount.clamp(2, 6);

  // Spark slack tightens through the sector (sawtooth).
  final slack = switch (phase) {
    1 => 3,
    2 => 2,
    3 => 1,
    4 => 2,
    _ => 2,
  };
  final sparks = starCount + slack;
  final par = starCount; // 3 stars = ~one spark per star

  // Multi-hit stars appear in the final sector.
  final multiHit = sector == 5;

  final placed = <Point<double>>[];
  final anchor = Point(boardWidth / 2, boardHeight - 12);

  Point<double> placeAway(double minY, double maxY) {
    for (var attempt = 0; attempt < 60; attempt++) {
      final p = Point(
        12 + rng.nextDouble() * (boardWidth - 24),
        minY + rng.nextDouble() * (maxY - minY),
      );
      final farFromAnchor = p.distanceTo(anchor) > 30;
      final farFromOthers = placed.every((q) => p.distanceTo(q) > 14);
      if (farFromAnchor && farFromOthers) {
        placed.add(p);
        return p;
      }
    }
    final p = Point(
      12 + rng.nextDouble() * (boardWidth - 24),
      minY + rng.nextDouble() * (maxY - minY),
    );
    placed.add(p);
    return p;
  }

  final stars = <Map<String, dynamic>>[];
  for (var i = 0; i < starCount; i++) {
    final p = placeAway(18, boardHeight * 0.62);
    final star = <String, dynamic>{
      'type': 'star',
      'x': _round(p.x),
      'y': _round(p.y),
    };
    if (multiHit && i == 0 && phase >= 2) {
      star['params'] = {'hits': 2};
    }
    stars.add(star);
  }

  // Element budget grows with difficulty.
  final elementBudget = switch (phase) {
    1 => idx >= 8 && sector == 1 ? 1 : (sector >= 2 ? 1 : 0),
    2 => 2,
    3 => 3,
    4 => 1,
    _ => 3,
  };

  final elements = <Map<String, dynamic>>[];
  final palette = _mechanicsFor(sector, idx);
  for (var i = 0; i < elementBudget; i++) {
    final type = palette[rng.nextInt(palette.length)];
    final p = placeAway(40, boardHeight * 0.72);
    elements.add(_element(type, p, rng));
  }

  final level = <String, dynamic>{
    'id': id,
    'sector': sector,
    'sparks': sparks,
    'parForThreeStars': par,
    'stars': stars,
    'elements': elements,
  };
  if (idx <= 3) level['introMechanic'] = sectorIntro[sector - 1];
  return level;
}

/// The mechanic palette available at a given sector/level (cumulative).
List<String> _mechanicsFor(int sector, int idx) {
  final list = <String>['wall'];
  if (sector >= 1 && (idx >= 8 || sector >= 2)) list.add('bumper');
  if (sector >= 2) list.add('gravity_well');
  if (sector >= 3) {
    list
      ..add('black_hole')
      ..add('portal');
  }
  if (sector >= 5) list.add('gravity_well'); // weight wells higher late-game
  return list;
}

Map<String, dynamic> _element(String type, Point<double> p, Random rng) {
  final base = {'type': type, 'x': _round(p.x), 'y': _round(p.y)};
  switch (type) {
    case 'wall':
      return {
        ...base,
        'params': {'w': 18 + rng.nextInt(14), 'h': 3},
      };
    case 'bumper':
      return {
        ...base,
        'params': {'w': 12 + rng.nextInt(8)},
      };
    case 'gravity_well':
      return {
        ...base,
        'params': {
          'radius': 16 + rng.nextInt(8),
          'strength': 500 + rng.nextInt(400),
        },
      };
    case 'black_hole':
      return {
        ...base,
        'params': {'radius': 4 + rng.nextInt(2)},
      };
    case 'portal':
      return {
        ...base,
        'params': {
          'radius': 3,
          'exitX': _round(12 + rng.nextDouble() * (boardWidth - 24)),
          'exitY': _round(30 + rng.nextDouble() * 40),
        },
      };
    default:
      return base;
  }
}

String _pad(int value, int width) => value.toString().padLeft(width, '0');

double _round(double v) => (v * 10).roundToDouble() / 10;
