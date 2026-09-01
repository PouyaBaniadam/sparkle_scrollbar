import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../configs/enums.dart';
import '../configs/particle_config.dart';
import '../configs/thumb_config.dart';
import '../configs/track_config.dart';

/// CustomPainter that binds all 31 dynamic floats to the GLSL shader.
class ShaderScrollbarPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double thumbTop;
  final double thumbBottom;
  final double activity;
  final double velocity;
  final Axis orientation;
  final ThumbConfig thumbConfig;
  final ParticleConfig particleConfig;
  final TrackConfig trackConfig;

  ShaderScrollbarPainter({
    required this.shader,
    required this.time,
    required this.thumbTop,
    required this.thumbBottom,
    required this.activity,
    required this.velocity,
    required this.orientation,
    required this.thumbConfig,
    required this.particleConfig,
    required this.trackConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    int idx = 0;

    // 0..6: Dimensions, Time, Geometry, Dynamics
    shader.setFloat(idx++, size.width);
    shader.setFloat(idx++, size.height);
    shader.setFloat(idx++, time);
    shader.setFloat(idx++, thumbTop);
    shader.setFloat(idx++, thumbBottom);
    shader.setFloat(idx++, activity);
    shader.setFloat(idx++, velocity);

    // 7..9: Thumb Color (RGB)
    shader.setFloat(idx++, ((thumbConfig.color.r * 255).round() / 255.0));
    shader.setFloat(idx++, ((thumbConfig.color.g * 255).round() / 255.0));
    shader.setFloat(idx++, ((thumbConfig.color.b * 255).round() / 255.0));

    // 10..12: Glow Color (RGB)
    shader.setFloat(idx++, ((thumbConfig.glowColor.r * 255).round() / 255.0));
    shader.setFloat(idx++, ((thumbConfig.glowColor.g * 255).round() / 255.0));
    shader.setFloat(idx++, ((thumbConfig.glowColor.b * 255).round() / 255.0));

    // 13..15: Particle Color (RGB)
    shader.setFloat(idx++, ((particleConfig.color.r * 255).round() / 255.0));
    shader.setFloat(idx++, ((particleConfig.color.g * 255).round() / 255.0));
    shader.setFloat(idx++, ((particleConfig.color.b * 255).round() / 255.0));

    // 16..18: Velocity Shift Color (RGB)
    shader.setFloat(
      idx++,
      ((particleConfig.velocityShiftColor.r * 255).round() / 255.0),
    );
    shader.setFloat(
      idx++,
      ((particleConfig.velocityShiftColor.g * 255).round() / 255.0),
    );
    shader.setFloat(
      idx++,
      ((particleConfig.velocityShiftColor.b * 255).round() / 255.0),
    );

    // 19..20: Thickness and Intensity
    shader.setFloat(idx++, thumbConfig.thickness);
    shader.setFloat(idx++, particleConfig.intensity);

    // 21..24: Particle Dynamics
    shader.setFloat(idx++, particleConfig.count.toDouble());
    shader.setFloat(idx++, particleConfig.minSize);
    shader.setFloat(idx++, particleConfig.maxSize);
    shader.setFloat(idx++, particleConfig.speed);

    // 25: Particle Shape Mode
    final shapeVal = switch (particleConfig.shape) {
      ParticleShape.circle => 0.0,
      ParticleShape.star => 1.0,
      ParticleShape.diamond => 2.0,
      ParticleShape.square => 3.0,
    };
    shader.setFloat(idx++, shapeVal);

    // 26..30: Features, Notches, Wave, Track Opacity, Orientation Flag
    shader.setFloat(idx++, particleConfig.enableColorShift ? 1.0 : 0.0);
    shader.setFloat(idx++, thumbConfig.gripNotchCount.toDouble());
    shader.setFloat(idx++, thumbConfig.enableWaveEffect ? 1.0 : 0.0);
    shader.setFloat(idx++, trackConfig.showTrack ? trackConfig.opacity : 0.0);
    shader.setFloat(idx++, orientation == Axis.horizontal ? 1.0 : 0.0);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant ShaderScrollbarPainter old) => true;
}
