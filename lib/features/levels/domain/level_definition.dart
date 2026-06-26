import 'package:equatable/equatable.dart';

/// A single obstacle/element placed on a level board (docs/LEVEL_DESIGN.md
/// data model). [type] maps to a Flame component; [params] carries
/// type-specific fields (e.g. radius, paired portal id, motion path).
class LevelElement extends Equatable {
  const LevelElement({
    required this.type,
    required this.x,
    required this.y,
    this.params = const {},
  });

  factory LevelElement.fromJson(Map<String, dynamic> json) => LevelElement(
    type: json['type'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    params: (json['params'] as Map<String, dynamic>?) ?? const {},
  );

  final String type;
  final double x;
  final double y;
  final Map<String, dynamic> params;

  @override
  List<Object?> get props => [type, x, y, params];
}

/// The handcrafted definition of one level, loaded from
/// `assets/levels/sector_xx/level_xxx.json`.
class LevelDefinition extends Equatable {
  const LevelDefinition({
    required this.id,
    required this.sector,
    required this.sparks,
    required this.parForThreeStars,
    required this.stars,
    required this.elements,
    this.introMechanic,
  });

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    final stars = (json['stars'] as List<dynamic>)
        .map((e) => LevelElement.fromJson(e as Map<String, dynamic>))
        .toList();
    final elements = (json['elements'] as List<dynamic>? ?? const [])
        .map((e) => LevelElement.fromJson(e as Map<String, dynamic>))
        .toList();
    return LevelDefinition(
      id: json['id'] as int,
      sector: json['sector'] as int,
      sparks: json['sparks'] as int,
      parForThreeStars: json['parForThreeStars'] as int,
      stars: stars,
      elements: elements,
      introMechanic: json['introMechanic'] as String?,
    );
  }

  final int id;
  final int sector;

  /// Number of sparks (shots) the player is given for this level.
  final int sparks;

  /// Max sparks used to still earn 3 stars.
  final int parForThreeStars;

  /// Dim-star targets that must all be lit to win.
  final List<LevelElement> stars;

  /// Obstacles, bumpers, wells, portals, etc.
  final List<LevelElement> elements;

  /// Name of the mechanic this level introduces, if any (drives tutorial hints).
  final String? introMechanic;

  @override
  List<Object?> get props => [
    id,
    sector,
    sparks,
    parForThreeStars,
    stars,
    elements,
    introMechanic,
  ];
}
