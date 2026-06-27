import 'dart:async';

import 'package:flutter/services.dart';

/// App-owned haptics interface. Honors the user's "Haptics" setting via
/// `setEnabled` (docs/UI_GUIDELINES.md §3.8).
abstract interface class HapticsService {
  /// Enables or disables haptic feedback (mirrors the user setting).
  void setEnabled({required bool enabled});

  /// Light selection tick (button taps, aiming).
  void selection();

  /// Light impact (spark launch, star lit).
  void light();

  /// Medium impact (win).
  void medium();
}

/// Real haptics via the platform [HapticFeedback] channel.
class PlatformHapticsService implements HapticsService {
  bool _enabled = true;

  @override
  void setEnabled({required bool enabled}) => _enabled = enabled;

  @override
  void selection() {
    if (_enabled) unawaited(HapticFeedback.selectionClick());
  }

  @override
  void light() {
    if (_enabled) unawaited(HapticFeedback.lightImpact());
  }

  @override
  void medium() {
    if (_enabled) unawaited(HapticFeedback.mediumImpact());
  }
}

/// No-op haptics (tests / unsupported platforms).
class NoopHapticsService implements HapticsService {
  @override
  void setEnabled({required bool enabled}) {}

  @override
  void selection() {}

  @override
  void light() {}

  @override
  void medium() {}
}
