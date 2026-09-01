import 'package:flutter/material.dart';

import '../configs/enums.dart';
import '../configs/thumb_config.dart';
import '../configs/track_config.dart';

/// Minimal, high-performance canvas painter for classic mode (both vertical and horizontal).
class ClassicScrollbarPainter extends CustomPainter {
  final double thumbTop;
  final double thumbBottom;
  final double activity;
  final Axis orientation;
  final ScrollbarAlignment alignment;
  final ThumbConfig thumbConfig;
  final TrackConfig trackConfig;

  ClassicScrollbarPainter({
    required this.thumbTop,
    required this.thumbBottom,
    required this.activity,
    required this.orientation,
    required this.alignment,
    required this.thumbConfig,
    required this.trackConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double barSize = 6.0;
    const double padding = 6.0;
    final isHoriz = orientation == Axis.horizontal;

    final double mainDimension = isHoriz ? size.width : size.height;
    final double crossDimension = isHoriz ? size.height : size.width;

    double crossPos;
    if (isHoriz) {
      crossPos = alignment == ScrollbarAlignment.top
          ? padding
          : crossDimension - barSize - padding;
    } else {
      crossPos = alignment == ScrollbarAlignment.left
          ? padding
          : crossDimension - barSize - padding;
    }

    // 1. Draw track
    if (trackConfig.showTrack) {
      final trackPaint = Paint()
        ..color = (trackConfig.color ?? thumbConfig.color).withValues(
          alpha: trackConfig.opacity,
        )
        ..style = PaintingStyle.fill;

      final Rect trackRect = isHoriz
          ? Rect.fromLTWH(8, crossPos, mainDimension - 16, barSize)
          : Rect.fromLTWH(crossPos, 8, barSize, mainDimension - 16);

      canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, const Radius.circular(10)),
        trackPaint,
      );
    }

    // 2. Compute thumb metrics
    final start = (thumbTop * mainDimension).clamp(8.0, mainDimension - 28.0);
    final end = (thumbBottom * mainDimension).clamp(
      start + 20.0,
      mainDimension - 8.0,
    );
    final thumbLength = end - start;

    final thumbColor = Color.lerp(
      thumbConfig.color.withValues(alpha: 0.45),
      thumbConfig.glowColor.withValues(alpha: 0.95),
      activity,
    )!;

    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    final Rect thumbRect = isHoriz
        ? Rect.fromLTWH(start, crossPos, thumbLength, barSize)
        : Rect.fromLTWH(crossPos, start, barSize, thumbLength);

    final thumbRRect = RRect.fromRectAndRadius(
      thumbRect,
      const Radius.circular(10),
    );

    // Glow shadow during active scrolling
    if (activity > 0.05) {
      final shadowPaint = Paint()
        ..color = thumbConfig.glowColor.withValues(alpha: 0.35 * activity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawRRect(thumbRRect, shadowPaint);
    }

    canvas.drawRRect(thumbRRect, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant ClassicScrollbarPainter old) => true;
}
