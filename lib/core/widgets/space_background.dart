import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/nova_context.dart';

/// The standard "lofi space" backdrop: the vertical space gradient with an
/// optional static starfield painted on top (docs/DESIGN_SYSTEM.md §4.11).
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({this.showStars = true, this.child, super.key});

  final bool showStars;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.nova.spaceGradient),
      child: showStars
          ? CustomPaint(painter: const _StarfieldPainter(), child: child)
          : child,
    );
  }
}

/// A calm, static starfield. Star positions are seeded so they never flicker
/// between rebuilds.
class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  static const int _starCount = 80;
  static const int _seed = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(_seed);
    final paint = Paint()..color = AppColors.onHigh;
    for (var i = 0; i < _starCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.2;
      paint.color = AppColors.onHigh.withValues(
        alpha: random.nextDouble() * 0.5 + 0.1,
      );
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => false;
}

/// The canonical NovaPlay scaffold: [SpaceBackground] + safe areas + an
/// optional transparent app bar. Prefer this over a bare [Scaffold].
class NovaScaffold extends StatelessWidget {
  const NovaScaffold({
    required this.body,
    this.appBar,
    this.showStars = true,
    this.floatingActionButton,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showStars;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SpaceBackground(
        showStars: showStars,
        child: SafeArea(child: body),
      ),
    );
  }
}
