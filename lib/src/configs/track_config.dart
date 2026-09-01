import 'package:flutter/material.dart';

/// Configuration for the background groove track.
class TrackConfig {
  /// Whether the background groove track is visible. Default is `true`.
  final bool showTrack;

  /// Custom color of the background track (defaults to thumb color tint if null).
  final Color? color;

  /// Opacity multiplier for the background groove track (0.0 to 1.0). Default is `0.15`.
  final double opacity;

  const TrackConfig({this.showTrack = true, this.color, this.opacity = 0.15});

  /// Hides the background track completely.
  const TrackConfig.hidden()
    : showTrack = false,
      color = Colors.transparent,
      opacity = 0.0;
}
