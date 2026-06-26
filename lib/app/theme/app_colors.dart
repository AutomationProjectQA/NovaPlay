import 'package:flutter/material.dart';

/// NovaPlay color tokens. Values mirror docs/DESIGN_SYSTEM.md (dark-first
/// "lofi space" palette). Never use raw hex outside this file — reference these
/// tokens or the `NovaTheme` extension instead.
abstract final class AppColors {
  // ── Space / backgrounds ──
  static const Color space900 = Color(0xFF05060E);
  static const Color space800 = Color(0xFF0A0C1A);
  static const Color space700 = Color(0xFF11142A);
  static const Color space600 = Color(0xFF1A1E3C);

  // ── Surfaces ──
  static const Color surfaceBase = Color(0xFF0F1226);
  static const Color surfaceRaised = Color(0xFF171B36);
  static const Color surfaceOverlay = Color(0xFF1E2342);

  // ── Text / on-colors ──
  static const Color onHigh = Color(0xFFF4F6FF);
  static const Color onMedium = Color(0xFFAEB4D6);
  static const Color onDisabled = Color(0xFF5C6182);

  // ── Nova accent (the spark / primary) ──
  static const Color nova500 = Color(0xFFFFC857);
  static const Color nova400 = Color(0xFFFFD884);
  static const Color nova600 = Color(0xFFE0A53C);

  // ── Stars & currencies ──
  static const Color starDim = Color(0xFF5C6182);
  static const Color starLit = Color(0xFFFFE6A8);
  static const Color stardust = Color(0xFFA98BFF);
  static const Color coin = Color(0xFFFFC857);

  // ── Sector accents ──
  static const Color sectorEmbers = Color(0xFFFF8A5C);
  static const Color sectorNebula = Color(0xFFC77DFF);
  static const Color sectorVoid = Color(0xFF4DA3FF);
  static const Color sectorPulsar = Color(0xFF3FD0C9);
  static const Color sectorSingularity = Color(0xFFF2F4FF);

  // ── Semantic ──
  static const Color success = Color(0xFF3FD98B);
  static const Color warn = Color(0xFFFFB547);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4DA3FF);

  /// Default full-screen background gradient (space.600 → space.800 → space.900).
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [space600, space800, space900],
  );
}
