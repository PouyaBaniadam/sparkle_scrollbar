import 'package:flutter/material.dart';

import 'enums.dart';

/// Builder signature for custom scroll tooltip contents.
typedef ScrollTooltipBuilder = Widget Function(
  BuildContext context,
  double scrollFraction,
  double currentPixels,
  double maxPixels,
);

/// Configuration for the floating position indicator bubble alongside the active thumb.
class ScrollTooltipConfig {
  /// When the tooltip indicator bubble should be displayed.
  final ScrollbarTooltipMode mode;

  /// Custom builder for custom tooltip contents (e.g., section headers, dates, alphabet index).
  final ScrollTooltipBuilder? builder;

  /// Distance offset from the scrollbar track in pixels. Default is `12.0`.
  final double offset;

  /// Background color of the default bubble container.
  final Color backgroundColor;

  /// Text color inside the default bubble.
  final Color textColor;

  /// Border radius curvature of the bubble container.
  final double borderRadius;

  const ScrollTooltipConfig({
    this.mode = ScrollbarTooltipMode.none,
    this.builder,
    this.offset = 12.0,
    this.backgroundColor = const Color(0xFF1E2230),
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
  });

  /// Factory constructor for a pre-built percentage indicator tooltip bubble.
  factory ScrollTooltipConfig.percentage({
    ScrollbarTooltipMode mode = ScrollbarTooltipMode.onDragOnly,
    Color backgroundColor = const Color(0xFF1E2230),
    Color textColor = Colors.white,
  }) {
    return ScrollTooltipConfig(
      mode: mode,
      backgroundColor: backgroundColor,
      textColor: textColor,
      builder: (context, fraction, pixels, maxPixels) {
        final percent = (fraction * 100).clamp(0, 100).toInt();
        return Text(
          "$percent%",
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
