import 'package:flutter/material.dart';

import '../configs/enums.dart';
import '../configs/tooltip_config.dart';

/// Floating indicator bubble displaying exact position alongside the active thumb.
class ScrollTooltipBubble extends StatelessWidget {
  final double thumbTop;
  final double thumbBottom;
  final double trackDimension;
  final double scrollFraction;
  final double currentPixels;
  final double maxPixels;
  final bool isVisible;
  final Axis orientation;
  final ScrollbarAlignment alignment;
  final ScrollTooltipConfig config;

  const ScrollTooltipBubble({
    super.key,
    required this.thumbTop,
    required this.thumbBottom,
    required this.trackDimension,
    required this.scrollFraction,
    required this.currentPixels,
    required this.maxPixels,
    required this.isVisible,
    required this.orientation,
    required this.alignment,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || config.mode == ScrollbarTooltipMode.none) {
      return const SizedBox.shrink();
    }

    final isHoriz = orientation == Axis.horizontal;
    final centerPos = ((thumbTop + thumbBottom) * 0.5 * trackDimension).clamp(
      24.0,
      trackDimension - 24.0,
    );

    final content = config.builder != null
        ? config.builder!(context, scrollFraction, currentPixels, maxPixels)
        : Text(
            "${(scrollFraction * 100).toInt()}%",
            style: TextStyle(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );

    double? top, bottom, left, right;
    if (isHoriz) {
      left = centerPos - 20;
      if (alignment == ScrollbarAlignment.top) {
        top = config.offset + 24;
      } else {
        bottom = config.offset + 24;
      }
    } else {
      top = centerPos - 16;
      if (alignment == ScrollbarAlignment.left) {
        left = config.offset + 24;
      } else {
        right = config.offset + 24;
      }
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(config.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: content,
        ),
      ),
    );
  }
}
