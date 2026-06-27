/// Tunable constants for the deterministic spark physics (docs/ARCHITECTURE.md
/// §8.3, §8.8). All values are in the level's virtual coordinate space
/// (see [PhysicsConstants.boardWidth]/[PhysicsConstants.boardHeight]).
abstract final class PhysicsConstants {
  /// Authoring board size. Levels are designed in this space; the camera fits
  /// it to the viewport (docs/LEVEL_DESIGN.md coordinate system).
  static const double boardWidth = 100;
  static const double boardHeight = 160;

  /// Fixed physics step (120 Hz) for determinism, independent of frame rate.
  static const double fixedDt = 1 / 120;

  /// Largest real frame we integrate, to avoid the spiral-of-death after a hitch.
  static const double maxFrame = 0.25;

  /// Spark collision radius.
  static const double sparkRadius = 1.6;

  /// Velocity retained per second (space drag). The spark coasts, slowly
  /// bleeding speed so every shot terminates.
  static const double dampingPerSecond = 0.55;

  /// Below this speed the shot is considered over (spark has settled).
  static const double minSpeed = 4;

  /// Launch speed ceiling, mapped from the drag length.
  static const double maxLaunchSpeed = 160;

  /// Drag length (virtual units) that maps to [maxLaunchSpeed].
  static const double maxDragLength = 60;

  /// Hard cap on a single shot's duration (safety net against perpetual motion).
  static const double maxShotSeconds = 9;

  /// Energy multiplier applied by a bumper on bounce.
  static const double bumperGain = 1.25;

  /// Max bounces resolved within one integration step (anti-jitter bound).
  static const int maxBouncesPerStep = 4;

  /// Trajectory-preview sampling: max simulated steps and how often to emit a
  /// point. The "Guided Line" booster raises [previewMaxSteps].
  static const int previewMaxSteps = 360;
  static const int previewSampleEvery = 4;
}
