import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// A short radial spark burst emitted when a star lights (docs/DESIGN_SYSTEM.md
/// §5 "calm spectacle"). Self-removes when its particles expire.
ParticleSystemComponent sparkBurst(Vector2 position, {int seed = 0}) {
  final rng = math.Random(seed);
  const count = 10;
  return ParticleSystemComponent(
    position: position.clone(),
    priority: 45,
    particle: Particle.generate(
      // count defaults to 10 — kept in [count] for the angle math below.
      generator: (i) {
        final angle = (i / count) * 2 * math.pi;
        final speed = 14 + rng.nextDouble() * 12;
        return AcceleratedParticle(
          speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
          child: CircleParticle(
            radius: 0.9,
            paint: Paint()..color = AppColors.nova400,
          ),
        );
      },
    ),
  );
}
