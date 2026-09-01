import 'package:flutter/material.dart';

import 'enums.dart';

/// Configuration for particle effects, emission geometry, and velocity color dynamics.
class ParticleConfig {
  /// Maximum number of simultaneous active particles (clamped between 0 and 50).
  ///
  /// Setting this to `0` disables particle emission.
  final int count;

  /// Minimum particle radius size in relative shader units. Default is `0.035`.
  final double minSize;

  /// Maximum particle radius size in relative shader units. Default is `0.075`.
  final double maxSize;

  /// Speed multiplier launching particles in the opposite direction of scrolling. Default is `1.0`.
  final double speed;

  /// Overall glow brightness and bloom multiplier. Default is `1.0`.
  final double intensity;

  /// Base primary color of emitted particles.
  final Color color;

  /// Target color interpolated when scrolling at high velocities (if [enableColorShift] is true).
  final Color velocityShiftColor;

  /// Whether to interpolate particle color dynamically as scroll speed increases.
  final bool enableColorShift;

  /// The visual geometric shape of the particles. Default is [ParticleShape.circle].
  final ParticleShape shape;

  const ParticleConfig({
    this.count = 25,
    this.minSize = 0.035,
    this.maxSize = 0.075,
    this.speed = 1.0,
    this.intensity = 1.0,
    this.color = const Color(0xFFE0F4FF),
    this.velocityShiftColor = const Color(0xFFFF5252),
    this.enableColorShift = false,
    this.shape = ParticleShape.circle,
  });

  /// Automatically generates matching harmonious spark colors keeping the pure hue of [baseColor].
  factory ParticleConfig.fromColor(
    Color baseColor, {
    int count = 25,
    double speed = 1.0,
    double size = 0.065,
    ParticleShape shape = ParticleShape.star,
    bool enableColorShift = true,
    Color? velocityShiftColor,
  }) {
    final hsl = HSLColor.fromColor(baseColor);

    final sparkColor = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 0.95))
        .withSaturation((hsl.saturation * 1.1).clamp(0.0, 1.0))
        .toColor();

    final shiftColor =
        velocityShiftColor ??
        hsl
            .withHue((hsl.hue + 15.0) % 360.0)
            .withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0))
            .toColor();

    return ParticleConfig(
      count: count,
      minSize: size * 0.55,
      maxSize: size,
      speed: speed,
      color: sparkColor,
      velocityShiftColor: shiftColor,
      enableColorShift: enableColorShift,
      shape: shape,
    );
  }

  /// Disables particle emission completely.
  const ParticleConfig.none()
    : count = 0,
      minSize = 0.0,
      maxSize = 0.0,
      speed = 0.0,
      intensity = 0.0,
      color = Colors.transparent,
      velocityShiftColor = Colors.transparent,
      enableColorShift = false,
      shape = ParticleShape.circle;
}
