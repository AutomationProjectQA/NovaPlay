import 'package:flame/components.dart';
import 'package:novaplay/features/levels/domain/level_definition.dart';
import 'package:novaplay/game/components/field_components.dart';
import 'package:novaplay/game/components/star_component.dart';
import 'package:novaplay/game/physics/colliders.dart';
import 'package:novaplay/game/physics/physics_constants.dart';

/// The assembled physics field + visual components for one level, produced from
/// a [LevelDefinition] (docs/ARCHITECTURE.md §8.2 "data-driven").
class LevelField {
  LevelField({
    required this.segments,
    required this.wells,
    required this.holes,
    required this.stars,
    required this.portals,
    required this.circles,
    required this.visuals,
    required this.starComponents,
    required this.asteroidComponents,
    required this.launchAnchor,
  });

  final List<SegmentCollider> segments;
  final List<GravityWell> wells;
  final List<BlackHole> holes;
  final List<StarTarget> stars;
  final List<Portal> portals;
  final List<CircleCollider> circles;

  /// Flame components to add to the world (walls, wells, holes, portals, stars).
  final List<Component> visuals;

  /// Star visuals aligned 1:1 with [stars] by index, so the engine can light
  /// the matching component.
  final List<StarComponent> starComponents;

  /// Asteroid visuals aligned 1:1 with [circles] by index, so moving asteroids
  /// can be repositioned in lock-step with the simulation.
  final List<AsteroidComponent> asteroidComponents;

  final Vector2 launchAnchor;
}

/// Reads a [LevelDefinition] and produces its [LevelField].
LevelField buildLevelField(LevelDefinition level) {
  final segments = boardBoundaries();
  final wells = <GravityWell>[];
  final holes = <BlackHole>[];
  final stars = <StarTarget>[];
  final portals = <Portal>[];
  final circles = <CircleCollider>[];
  final visuals = <Component>[];
  final starComponents = <StarComponent>[];
  final asteroidComponents = <AsteroidComponent>[];

  for (final s in level.stars) {
    final center = Vector2(s.x, s.y);
    final radius = _p(s.params, 'radius', 3);
    stars.add(
      StarTarget(
        center: center,
        radius: radius,
        hitsRequired: _pi(s.params, 'hits', 1),
      ),
    );
    final comp = StarComponent(position: center, radius: radius);
    starComponents.add(comp);
    visuals.add(comp);
  }

  for (final e in level.elements) {
    final center = Vector2(e.x, e.y);
    switch (e.type) {
      case 'wall':
        _addRect(center, e.params, segments, visuals, bounce: 1);
      case 'bumper':
        final w = _p(e.params, 'w', 12);
        final start = Vector2(e.x - w / 2, e.y);
        final end = Vector2(e.x + w / 2, e.y);
        segments.add(
          SegmentCollider(start, end, bounce: PhysicsConstants.bumperGain),
        );
        visuals.add(WallComponent(start: start, end: end, isBumper: true));
      case 'gravity_well':
        final radius = _p(e.params, 'radius', 18);
        wells.add(
          GravityWell(
            center: center,
            radius: radius,
            strength: _p(e.params, 'strength', 600),
          ),
        );
        visuals.add(GravityWellComponent(center: center, radius: radius));
      case 'black_hole':
        final radius = _p(e.params, 'radius', 4);
        holes.add(BlackHole(center: center, radius: radius));
        visuals.add(BlackHoleComponent(center: center, radius: radius));
      case 'portal':
        final radius = _p(e.params, 'radius', 3);
        final exit = Vector2(
          _p(e.params, 'exitX', e.x),
          _p(e.params, 'exitY', e.y),
        );
        portals.add(Portal(entry: center, exit: exit, radius: radius));
        visuals
          ..add(PortalComponent(center: center, radius: radius))
          ..add(PortalComponent(center: exit, radius: radius));
      case 'asteroid':
        final radius = _p(e.params, 'radius', 5);
        // Optional sinusoidal motion → a moving obstacle.
        final motion =
            e.params.containsKey('toX') || e.params.containsKey('toY')
            ? ColliderMotion(
                to: Vector2(_p(e.params, 'toX', e.x), _p(e.params, 'toY', e.y)),
                period: _p(e.params, 'period', 3),
                phase: _p(e.params, 'phase', 0),
              )
            : null;
        circles.add(
          CircleCollider(
            home: center,
            radius: radius,
            bounce: _p(e.params, 'bounce', 1),
            motion: motion,
          ),
        );
        final comp = AsteroidComponent(center: center, radius: radius);
        asteroidComponents.add(comp);
        visuals.add(comp);
    }
  }

  final anchor = Vector2(
    PhysicsConstants.boardWidth / 2,
    PhysicsConstants.boardHeight - 12,
  );

  return LevelField(
    segments: segments,
    wells: wells,
    holes: holes,
    stars: stars,
    portals: portals,
    circles: circles,
    visuals: visuals,
    starComponents: starComponents,
    asteroidComponents: asteroidComponents,
    launchAnchor: anchor,
  );
}

void _addRect(
  Vector2 center,
  Map<String, dynamic> params,
  List<SegmentCollider> segments,
  List<Component> visuals, {
  required double bounce,
}) {
  final w = _p(params, 'w', 16);
  final h = _p(params, 'h', 4);
  final tl = Vector2(center.x - w / 2, center.y - h / 2);
  final tr = Vector2(center.x + w / 2, center.y - h / 2);
  final br = Vector2(center.x + w / 2, center.y + h / 2);
  final bl = Vector2(center.x - w / 2, center.y + h / 2);
  for (final (a, b) in [(tl, tr), (tr, br), (br, bl), (bl, tl)]) {
    segments.add(SegmentCollider(a, b, bounce: bounce));
    visuals.add(WallComponent(start: a, end: b));
  }
}

double _p(Map<String, dynamic> params, String key, double fallback) =>
    (params[key] as num?)?.toDouble() ?? fallback;

int _pi(Map<String, dynamic> params, String key, int fallback) =>
    (params[key] as num?)?.toInt() ?? fallback;
