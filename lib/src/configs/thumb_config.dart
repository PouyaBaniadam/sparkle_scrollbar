import 'package:flutter/material.dart';

/// Configuration for the draggable scrollbar thumb capsule appearance and material.
class ThumbConfig {
  /// Thickness radius of the thumb capsule (relative scale 0.05 to 0.16). Default is `0.095`.
  final double thickness;

  /// Base primary color of the thumb body.
  final Color color;

  /// Outer aura glow and highlight reflection color.
  final Color glowColor;

  /// Number of mechanical center grip ridges carved into the thumb body (0, 1, or 3). Default is `3`.
  final int gripNotchCount;

  /// Enables a continuous animated sinusoidal light wave traveling along the thumb body.
  final bool enableWaveEffect;

  const ThumbConfig({
    this.thickness = 0.095,
    this.color = const Color(0xFF00E5FF),
    this.glowColor = const Color(0xFF18FFFF),
    this.gripNotchCount = 3,
    this.enableWaveEffect = true,
  });

  /// Automatically generates a matching glow highlight from a single [baseColor].
  factory ThumbConfig.fromColor(
    Color baseColor, {
    double thickness = 0.095,
    int gripNotches = 3,
    bool enableWave = true,
  }) {
    final hsl = HSLColor.fromColor(baseColor);
    final glow = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
        .toColor();

    return ThumbConfig(
      color: baseColor,
      glowColor: glow,
      thickness: thickness,
      gripNotchCount: gripNotches,
      enableWaveEffect: enableWave,
    );
  }
}
