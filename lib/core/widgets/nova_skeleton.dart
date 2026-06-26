import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/app_colors.dart';

/// A shimmering placeholder block shown while content loads
/// (docs/DESIGN_SYSTEM.md §4.11). Respects reduced motion by holding static.
class NovaSkeleton extends StatefulWidget {
  const NovaSkeleton({
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<NovaSkeleton> createState() => _NovaSkeletonState();
}

class _NovaSkeletonState extends State<NovaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: reducedMotion
            ? const ColoredBox(color: AppColors.surfaceRaised)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [
                          AppColors.surfaceBase,
                          AppColors.surfaceOverlay,
                          AppColors.surfaceBase,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1 - 2 * _controller.value, 0),
                        end: Alignment(1 - 2 * _controller.value, 0),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
